require 'cmd/install'

def usage
  puts 'brew rebuild [--installed|--recurse] [formulae]'
end

def rebuild
  named = ARGV.named
  remarr = named + %w{--installed --recurse}
  @mode = OpenStruct.new(
    :all?        => ARGV.include?('--installed'),
    :recursive?  => (ARGV.include?('--recurse') && !ARGV.include?('--installed'))
  )
  @clean_ARGV = ARGV.clone.delete_if{|x| remarr.include? x}

  if @mode.all?
    @formulae = Formula.installed
  else
    @formulae = ARGV.formulae
  end

  if @formulae.empty?
    usage
    odie "No formula specified"
  end

  @dep_map = Hash.new{|h,k| h[k] = k.deps}
  @req_map = Hash.new{|h,k| h[k] = k.requirements}
  @rebuilt = []
  list = []
  @formulae.each do |formula|
    list |= rebuild_list formula, @mode.recursive?, list
  end
  list = sort_deps list
  list.each do |f|
    reinstall f
  end
end

def uses_formula formula
  uses = []
  Formula.installed.each do |f|
    uses << f if @dep_map[f].any? { |dep| dep.name == formula.name } || @req_map[f].any? { |req| req.name == formula.name }
  end
  uses
end

def rebuild_list formula, recursive = true, reinst = []
  return if @rebuilt.include? formula
  targets = (uses_formula(formula) - @rebuilt) - reinst
  ft =  targets.find{|x| reinst.any?{|y| y.deps.any?{|z| z.name == x.name}}}
  ft =  reinst.find{|x| targets.any?{|y| y.deps.any?{|z| z.name == x.name}}}

  reinst =  reinst | targets.reverse
  if recursive
    more = true
    targets = reinst - @rebuilt
    while more
      targets = targets.map{|f| uses_formula f }.inject([], &:|) || []
      targets -= reinst
      more = !targets.empty?
      reinst = targets.reverse | reinst
    end
  end
  reinst.reverse
end

def sort_deps arr
  out = []
  arr = arr.dup
  while !arr.empty?
    curr = arr.slice!(0)
    if curr.deps.any?{|x| arr.any?{|y| y.name == x.name}}
      arr << curr
    else
      out << curr
    end
  end
  out
end

# copied from brew-reinstall with minor modifications

def reinstall formula
  # Add the used_options for each named formula separately so
  # that the options apply to the right formula.
  ARGV.replace(@clean_ARGV)
  ARGV << formula.name
  tab = Tab.for_name(formula.name)
  tab.used_options.each { |option| ARGV << option.to_s }
  if tab.built_as_bottle and not tab.poured_from_bottle
    ARGV << '--build-bottle'
  end

  begin
    oh1 "Reinstalling #{formula} #{ARGV.options_only*' '}"
    opt_link = formula.opt_prefix
    if opt_link.exist?
      keg = Keg.new(opt_link.realpath)
      backup keg
    end
    Homebrew.install_formula formula
  rescue Exception
    ignore_interrupts { restore_backup(keg, formula) }
    raise
  else
    backup_path(keg).rmtree if backup_path(keg).exist?
  end
end

def backup keg
  keg.unlink
  keg.rename backup_path(keg)
end

def restore_backup keg, formula
  path = backup_path(keg)
  if path.directory?
    path.rename keg
    keg.link unless formula.keg_only?
  end
end

def backup_path path
  Pathname.new "#{path}.reinstall"
end

rebuild

require 'formula'

class BrewRebuild < Formula
  homepage 'http://github.com/tduehr/homebrew-rebuid'
  url 'git://github.com/tduehr/homebrew-rebuild.git'
  version '0.5.0'

  skip_clean 'bin'

  def install
    bin.install 'brew-rebuild.rb'
    (bin+'brew-rebuild.rb').chmod 0755
  end
end
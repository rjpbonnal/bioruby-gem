require 'helper'
require 'fileutils'

$UNITTEST=true   # prevents github push

class TestBiorubyGem < Test::Unit::TestCase
  TEST_DIR = 'test/bioruby-biogem-test'
  def basic_generated_files(project_name)
    %W(Gemfile lib lib/bio-#{project_name}.rb LICENSE.txt Rakefile README.rdoc test test/helper.rb test/test_bio-#{project_name}.rb).map do |file_name_to_test|
      File.join("bioruby-#{project_name}",file_name_to_test)
    end
  end
  
  def setup
    # check and create test directory
    `git config --global user.email "git@example.com"` if `git config user.email`.empty?
    `git config --global user.name "GitExample"` if `git config user.name`.empty?
    FileUtils.rm_rf(TEST_DIR) if Dir.exist?(TEST_DIR)
    Dir.mkdir TEST_DIR
  end
  
  def teardown
    # check and remove test directory
    FileUtils.rm_rf TEST_DIR if Dir.exist?(TEST_DIR)
  end

  # This test creates a project named 'bioruby-biogem-test'.
  def test_create_basic_project
    project_name = "biogem-test"
    Dir.chdir(TEST_DIR) do
      application_exit = Bio::Gem::Generator::Application.run!('create',"--no-create-repo", "--user-name=\"fake_name\"", "--user-email=\"fake_email\"", "--github-username=\"fake_github_user\"","#{project_name}")
      basic_generated_files(project_name).each do |path| 
        assert File.exist?(path), path
      end
    end

  end
  
  def test_create_wrapper_project
    project_name = "biogem-test2"
    Dir.chdir(TEST_DIR) do
      application_exit = Bio::Gem::Generator::Application.run!('create','--with-wrapper',"--no-create-repo", "--user-name=\"fake_name\"", "--user-email=\"fake_email\"", "--github-username=\"fake_github_user\"","#{project_name}")
      basic_generated_files(project_name).each do |path| 
        assert File.exist?(path), path
      end
      assert File.read(File.join("bioruby-#{project_name}",'lib',"bio-#{project_name}","#{project_name}.rb")).match(/require 'systemu'/)
      assert File.read(File.join("bioruby-#{project_name}",'lib',"bio-#{project_name}","#{project_name}.rb")).match(/systemu command/)
      assert File.read(File.join("bioruby-#{project_name}",'Gemfile')).match(/gem "systemu"/)
    end    
  end
end

require "chefspec"
require File.expand_path(File.join(File.dirname(__FILE__), "..", "libraries", "block_device.rb"))

describe "aws_opsworks_ebs::default" do
  before do
    volume_not_exist = double("shellout_double")
    allow(volume_not_exist).to receive(:run_command)
    allow(volume_not_exist).to receive(:error?).and_return(true) # error -> does not exist

    allow(Mixlib::ShellOut).to receive(:new).with("blkid -s TYPE -o value /dev/xvdf").and_return(volume_not_exist)
    allow(File).to receive(:blockdev?).with("/dev/xvdf").and_return(true)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/etc/filesystems").and_return(false)
  end

  def converge(opts)
    chef_runner = ChefSpec::SoloRunner.new(opts) do |node|
      node.set["aws_opsworks_agent"]["resources"]["volumes"] = [
        {
          :name => "testimage",
          :device => "/dev/sdf",
          :mount_point => "/asdf"
        }
      ]
    end
    chef_runner.converge(described_recipe)
  end

  [
    ["ubuntu", "12.04"],
    ["ubuntu", "14.04"],
    ["amazon", "2014.09"],
    ["redhat", "7.0"]
  ].each do |platform, platform_version|
    it "should install xfs packages on #{platform}-#{platform_version}" do
      chef_run = converge(:platform => platform, :version => platform_version)
      expect(chef_run).to install_package("xfsprogs").with(:retries => 2)
    end
  end

  [
    ["redhat", "6.5"],
    ["centos", "6.5"]
  ].each do |platform, platform_version|
    it "should not install xfs packages on #{platform}-#{platform_version}" do
      chef_run = converge(:platform => platform, :version => platform_version)
      expect(chef_run).to_not install_package("xfsprogs")
    end

    it "should ignore volumes on #{platform}-#{platform_version}" do
      chef_run = converge(:platform => platform, :version => platform_version)
      expect(chef_run).to_not run_execute("mkfs -t xfs /dev/xvdf")
    end
  end

  it "formats the device" do
    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to run_execute("mkfs -t xfs /dev/xvdf")
  end

  it "creates mount point directory" do
    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to create_directory("/asdf").with(:mode => "0755")
  end

  it "mounts the volume" do
    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to enable_mount("/asdf").with(:options => ["relatime"], :fstype => "auto", :device => "/dev/xvdf")
    expect(chef_run).to mount_mount("/asdf").with(:options => ["relatime"], :fstype => "auto", :device => "/dev/xvdf")
  end

  it "should not mount the volume if mountpoint is empty" do
    chef_runner = ChefSpec::SoloRunner.new(:platform => "amazon", :version => "2014.09") do |node|
      node.set["aws_opsworks_agent"]["resources"]["volumes"] = [
        {
          :name => "testimage",
          :device => "/dev/sdf",
          :mount_point => nil
        }
      ]
    end
    chef_run  = chef_runner.converge(described_recipe)

    expect(chef_run).to_not enable_mount("/asdf").with(:options => ["relatime"], :fstype => "auto", :device => "/dev/xvdf")
    expect(chef_run).to_not mount_mount("/asdf").with(:options => ["relatime"], :fstype => "auto", :device => "/dev/xvdf")
  end

  it "should not touch /etc/filesystems if /etc/filesystems does not exists" do
    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to_not run_ruby_block("add xfs to list of known filesystems")
  end

  it "should add xfs to /etc/filesystems if /etc/filesystems exist" do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/etc/filesystems").and_return(true)

    file = double
    expect(File).to receive(:readlines).with("/etc/filesystems").and_return(file)
    expect(file).to receive(:map).and_return(%w(ext1 ext2 ext3))
    expect(File).to receive(:write).with("/etc/filesystems", %w(ext1 ext2 ext3 xfs).join("\n"))

    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to run_ruby_block("add xfs to list of known filesystems")
    chef_run.ruby_block("add xfs to list of known filesystems").old_run_action(:run)
  end

  it "should not add xfs to /etc/filesystems if xfs is already in /etc/filesystems" do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/etc/filesystems").and_return(true)

    file = double
    expect(File).to receive(:readlines).with("/etc/filesystems").and_return(file)
    expect(file).to receive(:map).and_return(%w(ext1 ext2 ext3 xfs))
    expect(File).to_not receive(:write)

    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to run_ruby_block("add xfs to list of known filesystems")
    chef_run.ruby_block("add xfs to list of known filesystems").old_run_action(:run)
  end

  it "should add xfs to /etc/filesystems before iso9660 if iso9660 is in /etc/filesystems" do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/etc/filesystems").and_return(true)

    file = double
    expect(File).to receive(:readlines).with("/etc/filesystems").and_return(file)
    expect(file).to receive(:map).and_return(%w(ext1 ext2 ext3 iso9660 ext4))
    expect(File).to receive(:write).with("/etc/filesystems", %w(ext1 ext2 ext3 xfs iso9660 ext4).join("\n"))

    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to run_ruby_block("add xfs to list of known filesystems")
    chef_run.ruby_block("add xfs to list of known filesystems").old_run_action(:run)
  end

  it "should not add xfs to /etc/filesystems before iso9660 if iso9660 and xfs are in /etc/filesystems" do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/etc/filesystems").and_return(true)

    file = double
    expect(File).to receive(:readlines).with("/etc/filesystems").and_return(file)
    expect(file).to receive(:map).and_return(%w(ext1 ext2 ext3 iso9660 xfs ext4))
    expect(File).to_not receive(:write)

    chef_run = converge(:platform => "amazon", :version => "2014.09")
    expect(chef_run).to run_ruby_block("add xfs to list of known filesystems")
    chef_run.ruby_block("add xfs to list of known filesystems").old_run_action(:run)
  end
end

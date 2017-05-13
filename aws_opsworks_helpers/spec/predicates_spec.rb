require "chefspec"
require File.expand_path(File.join(File.dirname(__FILE__), "..", "libraries", "predicates.rb"))

describe "aws_opsworks_helpers::predicates" do
  def ec2_data
    { "ec2" => { "some" => "data" }}
  end

  context "with infrastructure_class attribute" do
    def agent_data(infrastructure_class)
      { "aws_opsworks_agent" => { "command" => { "instance_id" => "my-id" },
                                  "resources" => {
                                    "instances" => [{ "instance_id" => "my-id",
                                                      "infrastructure_class" => infrastructure_class }]}}}
    end

    context "EC2 instance" do
      let(:node) do
        agent_data("ec2").merge(ec2_data)
      end

      it "reports on_premises? as false" do
        expect(on_premises?).to eql(false)
      end
    end

    context "EC2 instance imported as on-premises" do
      let(:node) do
        agent_data("on-premises").merge(ec2_data)
      end

      it "reports on_premises? as true" do
        expect(on_premises?).to eql(true)
      end
    end

    context "On-premises instance" do
      let(:node) do
        agent_data("on-premises")
      end

      it "reports on_premises? as true" do
        expect(on_premises?).to eql(true)
      end
    end

  end
end

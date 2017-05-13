require "chefspec"
require File.expand_path(File.join(File.dirname(__FILE__), "..", "libraries", "search.rb"))

describe "aws_opsworks_helpers::search" do
  let(:node) do
    {
      "aws_opsworks_agent" => {
        "command" => {
          "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803"
        },
        "resources" => {
          "layers" => [
            {
              "layer_id" => "72e98d37-f3bc-40a9-b094-9242575e2efa",
              "name" => "2015-09-10 13:57:05 +0200 3cd5",
              "shortname" => "custom76e7569c118c",
              "type" => "custom"
            },
            {
              "layer_id" => "72e98d37-f3bc-40a9-b094-9242575e2efb",
              "name" => "2015-09-10 13:57:05 +0200 3cd5",
              "shortname" => "custom76e7569c118c",
              "type" => "custom"
            }
          ],
          "instances" => [
            {
              "ami_id" => "ami-0f4cfd64",
              "architecture" => "x86_64",
              "auto_scaling_type" => nil,
              "availability_zone" => "us-east-1b",
              "created_at" => "2015-09-10T11:57:08+00:00",
              "ebs_optimized" => false,
              "ec2_instance_id" => "i-4818abeb",
              "elastic_ip" => nil,
              "hostname" => "58b480278519fd",
              "instance_id" => "caf8bad6-a103-4591-a857-809fc9e1edcb",
              "instance_type" => "m3.medium",
              "layer_ids" => [
                "72e98d37-f3bc-40a9-b094-9242575e2efa"
              ],
              "os" => "Amazon Linux 2015.03",
              "private_dns" => "ip-172-31-40-184.ec2.internal",
              "private_ip" => "172.31.40.184",
              "public_dns" => "ec2-52-20-240-149.compute-1.amazonaws.com",
              "public_ip" => "52.20.240.149",
              "root_device_type" => "ebs",
              "root_device_volume_id" => "vol-5add44b7",
              "ssh_host_dsa_key_fingerprint" => "2f:94:1d:19:2f:9b:de:44:f7:ba:fc:46:50:e6:dc:41",
              "ssh_host_rsa_key_fingerprint" => "e2:63:e3:7a:52:f5:d9:02:b6:48:53:1d:dd:70:f3:4f",
              "status" => "stopping",
              "subnet_id" => "subnet-3e1a3616",
              "virtualization_type" => "paravirtual"
            },
            {
              "ami_id" => "ami-094cfd62",
              "architecture" => "x86_64",
              "auto_scaling_type" => nil,
              "availability_zone" => "us-east-1b",
              "created_at" => "2015-09-10T12:53:22+00:00",
              "ebs_optimized" => false,
              "ec2_instance_id" => "i-cfa1136c",
              "elastic_ip" => nil,
              "hostname" => "custom76e7569c118c1",
              "instance_id" => "e0973c34-9f8c-42dd-af3f-44dc7cc03803",
              "instance_type" => "c3.large",
              "layer_ids" => [
                "72e98d37-f3bc-40a9-b094-9242575e2efa"
              ],
              "os" => "Amazon Linux 2015.03",
              "private_dns" => "ip-172-31-44-138.ec2.internal",
              "private_ip" => "172.31.44.138",
              "public_dns" => "ec2-52-3-122-127.compute-1.amazonaws.com",
              "public_ip" => "52.3.122.127",
              "root_device_type" => "instance-store",
              "root_device_volume_id" => nil,
              "ssh_host_dsa_key_fingerprint" => "08:1e:55:78:56:06:b1:b5:18:1b:33:8c:d5:cb:ac:66",
              "ssh_host_rsa_key_fingerprint" => "38:43:a9:cf:5a:0f:c6:05:c1:82:a2:d6:e7:23:5b:c8",
              "status" => "requested",
              "subnet_id" => "subnet-3e1a3616",
              "virtualization_type" => "paravirtual"
            }
          ],
          "ecs_clusters" => [
            {
              "ecs_cluster_arn" => "arn:aws:ecs:us-east-1:661258169979:cluster/local",
              "ecs_cluster_name" => "local"
            }
          ]
        }
      }
    }
  end

  it "returns the current instance_id" do
    expect(find_own_instance_id).to eq("e0973c34-9f8c-42dd-af3f-44dc7cc03803")
  end

  it "returns the instance object with the correct instance_id" do
    expect(find_instance["instance_id"]).to eq("e0973c34-9f8c-42dd-af3f-44dc7cc03803")
    expect(find_instance["hostname"]).to eq("custom76e7569c118c1")
  end

  it "returns the layer_ids with the correct instance_id" do
    expect(find_layer_ids).to eq(["72e98d37-f3bc-40a9-b094-9242575e2efa"])
  end

  it "returns the layer object with the correct layer_id" do
    expect(find_layers.map { |l| l["layer_id"] }).to eq(["72e98d37-f3bc-40a9-b094-9242575e2efa"])
    expect(find_layers.map { |l| l["name"] }).to eq(["2015-09-10 13:57:05 +0200 3cd5"])
  end

  it "returns right ecs cluster with ecs cluster arn" do
    expect(find_ecs_cluster("arn:aws:ecs:us-east-1:661258169979:cluster/local")).to eq({
      "ecs_cluster_arn" => "arn:aws:ecs:us-east-1:661258169979:cluster/local",
      "ecs_cluster_name" => "local"
    })
  end
end

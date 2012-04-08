require 'spec_helper'
require 'scrambler/site_metrics'
require 'csv'

module Scrambler
  describe SiteMetrics do
    csv = <<EOD
files,language,blank,comment,code,"http://cloc.sourceforge.net v 1.53  T=3.0 s (361.0 files/s, 75252.7 lines/s)"
891,Java,27019,43759,139025
144,XML,631,2212,9458
24,HTML,154,78,1014
12,Bourne Shell,224,487,998
8,JSP,25,0,177
1,ASP.Net,30,0,131
1,DTD,58,169,38
1,SQL,5,0,35
1,CSS,6,0,25
EOD
    it "parses csv audit reports" do
      sm      = SiteMetrics.new("workspace" => "foo")
      metrics = {}

      sm.parse_csv(CSV.parse(csv), metrics)

      metrics["Java"][:files].should be(891)
      metrics["XML"][:blank].should be(631)
      metrics["HTML"][:comment].should be(78)
      metrics["CSS"][:code].should be(25)
    end

    it "adds to any existing metrics" do
      sm      = SiteMetrics.new("workspace" => "foo")
      metrics = {}

      sm.parse_csv(CSV.parse(csv), metrics)
      sm.parse_csv(CSV.parse(csv), metrics)

      metrics["Java"][:files].should be(891 * 2)
      metrics["XML"][:blank].should be(631  * 2)
      metrics["HTML"][:comment].should be(78 * 2)
      metrics["CSS"][:code].should be(25 * 2)

    end
  end
end
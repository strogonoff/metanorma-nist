require "spec_helper"
require "metanorma"
require "fileutils"

RSpec.describe Metanorma::NIST::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::NIST::Processor)

  let(:processor) {
    registry.find_processor(:nist)
  }

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::NIST })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
    #{BLANK_HDR}
    #{AUTHORITY}
    <preface/>
<sections/>
</nist-standard>
    OUTPUT

    expect(strip_guid(processor.input_to_isodoc(input, nil))).to be_equivalent_to output
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    input = <<~"INPUT"
    <nist-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
        <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <p>Term2</p>
        </clause>
      </sections>
    </nist-standard>
    INPUT

    output = <<~"OUTPUT"
    <main class="main-section">
      <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
   <div id="H">
     <h1>1.&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</h1>
     <p>Term2</p>
   </div>
 </main>
    OUTPUT

    processor.output(input, "test.html", :html)

    expect(
      File.read("test.html", encoding: "utf-8").
      gsub(%r{^.*<main}m, "<main").
      gsub(%r{</main>.*}m, "</main>")
    ).to be_equivalent_to output

  end

end

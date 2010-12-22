describe QME::Importer::GenericImporter do
  before(:all) do
    @loader = load_measures
  end

  it "should import the the information relevant to determining cervical cancer screening status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0032/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    
    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0032'))
    measure_info = gi.parse(doc)

    measure_info['encounter_outpatient'].should include(1270598400)
    measure_info['pap_test'].should include(1269302400)
    measure_info['hysterectomy'].should be_empty
  end
  
  it "should import the the information relevant to determining pneumonia vaccination status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0043/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0043'))
    measure_info = gi.parse(doc)

    measure_info['vaccination'].should include(1248825600)
    measure_info['encounter'].should include(1270598400)
  end
end
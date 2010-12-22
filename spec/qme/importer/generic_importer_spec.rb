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
  
  it "should import the information relevant to determining high blood pressure" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0018/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    
    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0018'))
    measure_info = gi.parse(doc)

    measure_info['encounter_outpatient'].should include(1239062400)
    measure_info['hypertension'].should include(1258156800)
    measure_info['systolic_blood_pressure'].should include('date' => 1258156800, 'value' => '132')
    measure_info['diastolic_blood_pressure'].should include('date' => 1258156800, 'value' => '86')
    measure_info['pregnancy'].should be_empty
    measure_info['procedures_indicative_of_esrd'].should be_empty
    measure_info['esrd'].should be_empty
    
  end
  
  it "should import the the information relevant to determining diabetic eye exam measure status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/diabetes/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0055'))
    measure_info = gi.parse(doc)

    measure_info['encounter_acute_inpatient'].should include(1275177600)
    measure_info['encounter_non_acute_inpatient'].should include(1275177600)
    measure_info['encounter_outpatient'].should include(1275177600)
    measure_info['encounter_outpatient_opthamological_services'].should include(1275177600)
    
    measure_info['medications_indicative_of_diabetes'].should include(1275177600)

    measure_info['diagnosis_diabetes'].should include(1275177600)
    measure_info['diagnosis_gestational_diabetes'].should include(1275177600)
    measure_info['diagnosis_steroid_induced_diabetes'].should include(1275177600)
    measure_info['polycystic_ovaries'].should include(1275177600)
    
    measure_info['proceedure_eye_exam'].should include(1275177600)
  end
end
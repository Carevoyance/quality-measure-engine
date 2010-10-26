describe QME::MapReduce::Executor do

  before do
    @db = Mongo::Connection.new('localhost', 27017).db('test')
    @measures = Dir.glob('measures/*')
  end
  
  it 'should produce the expected results for each measure' do
    print "\n"
    @measures.each do |dir|
      # load db with measure and sample patient records
      measure_file = Dir.glob(File.join(dir,'*.json'))[0]
      patient_files = Dir.glob(File.join(dir, 'patients', '*.json'))
      measure = JSON.parse(File.read(measure_file))
      measure_id = measure['id']
      print "Validating measure #{measure_id}"
      @db.drop_collection('measures')
      @db.drop_collection('records')
      measure_collection = @db.create_collection('measures')
      record_collection = @db.create_collection('records')
      measure_collection.save(measure)
      patient_files.each do |patient_file|
        patient = JSON.parse(File.read(patient_file))
        record_collection.save(patient)
      end
      
      # load expected results
      result_file = File.join(dir, 'result', 'result.json')
      expected = JSON.parse(File.read(result_file))
      
      # evaulate measure using Map/Reduce and validate results
      executor = QME::MapReduce::Executor.new(@db)
      result = executor.measure_result(measure_id, :effective_date=>Time.gm(2010, 9, 19).to_i)
      result[:population].should eql(expected['initialPopulation'])
      result[:numerator].should eql(expected['numerator'])
      result[:denominator].should eql(expected['denominator'])
      result[:exceptions].should eql(expected['exclusions'])
      print " - done\n"
    end
  end
  
end

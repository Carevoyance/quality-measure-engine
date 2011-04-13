begin
  require 'cover_me'
rescue LoadError
  puts 'cover_me unavailable, running without code coverage measurement'
end
require 'bundler/setup'

PROJECT_ROOT = File.dirname(__FILE__) + '/../'

require PROJECT_ROOT + 'lib/quality-measure-engine'


Bundler.require(:test)


def load_bundle(bundle_dir = '.')
  loader = QME::Database::Loader.new('test')
  measures = Dir.glob('measures/*')
  loader.drop_collection('bundles')
  loader.drop_collection('measures')
  loader.save_bundle(bundle_dir,'bundles')
  loader
end

def load_measures
  loader = QME::Database::Loader.new('test')
  measure_dir = ENV['MEASURE_DIR'] || 'measures'
  measures = Dir.glob(File.join(measure_dir,'*'))
  loader.drop_collection('measures')
  measures.each do |dir|
    loader.save_measure(dir, 'measures')
  end
  
  loader
end

def measure_definition(loader, measure_id, sub_id=nil)
  map = QME::MapReduce::Executor.new(loader.get_db)
  map.measure_def(measure_id, sub_id)
end


def validate_measures(measure_dirs, loader)
  
   measure_dirs.each do |dir|
      # check for sample data
      fixture_dir = File.join('fixtures', 'measures', File.basename(dir))
      patient_files = Dir.glob(File.join(fixture_dir, 'patients', '*.json'))
      if patient_files.length==0
        puts "Skipping #{dir}, no sample data in #{fixture_dir}"
        next
      end

      puts "Parsing #{dir}"

      loader.drop_collection('bundles')
      loader.drop_collection('measures')
      loader.drop_collection('records')
      loader.drop_collection('query_cache')
      loader.drop_collection('patient_cache')
      
      # load db with measure
      measures = loader.save_measure(dir, 'measures')
      
      # load db with sample patient records
      patient_files.each do |patient_file|
        patient = JSON.parse(File.read(patient_file))
        loader.save('records', patient)
      end
        
      # load expected results
      result_file = File.join('fixtures', 'measures', File.basename(dir), 'result.json')
      expected = JSON.parse(File.read(result_file))
      
      # evaulate measure using Map/Reduce and validate results
      executor = QME::MapReduce::Executor.new(loader.get_db)
      measures.each do |measure|
        measure_id = measure['id']
        sub_id = measure['sub_id']
        puts "Validating measure #{measure_id}#{sub_id}"
        result = executor.measure_result(measure_id, sub_id,'effective_date'=>Time.gm(2010, 9, 19).to_i)
        if expected['initialPopulation'] == nil
          # multiple results for multi numerator/denominator measure
          # loop through list of results to find the matching one
          expected['results'].each do |expect|
            if expect['id'].eql?(measure_id) && (sub_id==nil || expect['sub_id'].eql?(sub_id))
              result['population'].should match_population(expect['initialPopulation'])
              result['numerator'].should match_numerator(expect['numerator'])
              result['denominator'].should match_denominator(expect['denominator'])
              result['exclusions'].should match_exclusions(expect['exclusions'])
              (result['numerator']+result['antinumerator']).should eql(expect['denominator'])
              break
            end
          end
        else
          result['population'].should match_population(expected['initialPopulation'])
          result['numerator'].should match_numerator(expected['numerator'])
          result['denominator'].should match_denominator(expected['denominator'])
          result['exclusions'].should match_exclusions(expected['exclusions'])
          (result['numerator']+result['antinumerator']).should eql(expected['denominator'])
        end
      end
      puts ' - done'
    end
  
end
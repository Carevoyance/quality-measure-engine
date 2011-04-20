module QME
  module MapReduce
    class BackgroundWorker
      
      @queue = :measure_result_caching
      
      def self.perform(measure_id, sub_id, effective_date, db_name)
        
        map = QME::MapReduce::Executor.new()
        result = map.measure_result(measure_id, sub_id, 'effective_date' => effective_date)
        puts "#{measure_id}#{sub_id}: p#{result['population']}, d#{result['denominator']}, n#{result['numerator']}, e#{result['exclusions']}"
      end
    end
  end
end
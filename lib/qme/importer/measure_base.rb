module QME
  module Importer

    # A base class for all measure HITSP C32 measure importers
    #
    # @abstract Should be subclassed and implementers should provide a parse method
    class MeasureBase
      
      # Anytime that the MeasureBase class is subclassed, it will inform the PatientImporter
      # that a new importer is being created
      def self.inherited(subclass)
         PatientImporter.instance.add_measure(subclass)
      end
      
      def self.measure_id
        @measure_id
      end
      
      def self.measure_sub_id
        @measure_sub_id
      end
      
      # Used by subclasses to define their identifiers
      def self.measure(identifiers={})
        @measure_id = identifiers[:id]
        
        if identifiers[:sub_id]
          @measure_sub_id = identifiers[:sub_id]
        end
      end

      # Creates a measure importer with the definition passed in
      #
      # @param [Hash] definition the parsed representation of the measure definition
      def initialize(definition)
        @definition = definition
      end
      
      def extract_measure_properties(patient_hash, doc)
        measure_info = parse(doc)
        patient_hash['measures'][@definition['id']] = measure_info
      end
      
      # Will find the code as a child of the element passed in based on a supplied
      # XPath expression. If the code is in the list of acceptable codes for the
      # property, it will find the effective time, convert it to an Integer
      # and set the property.
      #
      # If a property is not set, it will set the property with and Integer value. If
      # the property is already set, it will make sure that it is an Array, and append
      # the new value.
      #
      # @param [Nokogiri::XML::Node] parent_element The node to look for the code under. It is assumed
      #        that the effectiveTime element will be a direct child of this node
      # @param [String] xpath_expression The expression to get the code element
      # @param [String] property_name The name of the property as specified in the measure definition
      # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
      # @param [Hash] measure_info where all of the extracted measure information will be stored
      def create_property_from_code(parent_element, xpath_expression, property_name, measure_info)
        code_elements = parent_element.xpath(xpath_expression)
        code_elements.each do |code_element|
          if CodeSystemHelper.is_in_code_list?(code_element['codeSystem'], code_element['code'], property_name, @definition)
            if parent_element.at_xpath('cda:effectiveTime')['value']
              date = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime')['value'])
            elsif parent_element.at_xpath('cda:effectiveTime/cda:low')['value']
              date = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:low')['value'])
            end
            if measure_info[property_name]
              if measure_info[property_name].kind_of?(Array)
                measure_info[property_name]['date'] << date         
              else
                measure_info[property_name] = [measure_info[property_name], date]
              end
            else
              measure_info[property_name] = date
            end                  
          end
        end
      end
      
      # Will find the code as a child of the element passed in based on a supplied
      # XPath expression. If the code is in the list of acceptable codes for the
      # property, it will find the value, and set the property.
      #
      # If a property is not set, it will set the property with an Integer value. If
      # the property is already set, it will make sure that it is an Array, and append
      # the new value.
      #
      # @param [Nokogiri::XML::Node] parent_element The node to look for the code under. It is assumed
      #        that the value element will be a direct child of this node
      # @param [String] xpath_expression The expression to get the code element
      # @param [String] property_name The name of the property as specified in the measure definition
      # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
      # @param [Hash] measure_info where all of the extracted measure information will be stored
      def extract_property_value(parent_element, xpath_expression, property_name, measure_info)
        code_elements = parent_element.xpath(xpath_expression)
        code_elements.each do |code_element|
          if CodeSystemHelper.is_in_code_list?(code_element['codeSystem'], code_element['code'], property_name, @definition)
            if parent_element.at_xpath('cda:value')['value']
              value = parent_element.at_xpath('cda:value')['value']
              if measure_info[property_name]
                if measure_info[property_name].kind_of?(Array)
                  measure_info[property_name]['value'] << value         
                else
                  measure_info[property_name] = [measure_info[property_name], value]
                end
              else
                measure_info[property_name] = value
              end
            end     
          end
        end
      end
      
      # Finds encounter elements in the Encounters section using the following XPath expression
      #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
      #
      # @param [Nokogiri::XML::Node] doc The parsed C32 document
      # @yield [encounter_element] the block will be passed the encounter element
      def encounter_elements(doc)
        encounter_elements = doc.xpath("//cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter")
        encounter_elements.each do |encounter_element|
          yield encounter_element
        end
      end
    end
  end
end
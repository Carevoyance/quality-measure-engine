module QME
  module Importer
    # Class that can be used to create an importer for a section of a HITSP C32 document. It usually
    # operates by selecting all CDA entries in a section and then creates entries for them.
    class SectionImporter

      # Creates a new SectionImporter
      # @param [String] entry_xpath An XPath expression that can be used to find the desired entries
      # @param [String] code_xpath XPath expression to find the code element as a child of the desired CDA entry.
      #        Defaults to "./cda:code"
      # @param [String] status_xpath XPath expression to find the status element as a child of the desired CDA
      #        entry. Defaults to nil. If not provided, a status will not be checked for since it is not applicable
      #        to all enrty types
      def initialize(entry_xpath, code_xpath="./cda:code", status_xpath=nil)
        @entry_xpath = entry_xpath
        @code_xpath = code_xpath
        @status_xpath = status_xpath
      end

      # Traverses that HITSP C32 document passed in using XPath and creates an Array of Entry
      # objects based on what it finds
      # @param [Nokogiri::XML::Document] doc It is expected that the root node of this document
      #        will have the "cda" namespace registered to "urn:hl7-org:v3"
      #        measure definition
      # @return [Array] will be a list of Entry objects
      def create_entries(doc)
        entry_list = []
        entry_elements = doc.xpath(@entry_xpath)
        entry_elements.each do |entry_element|
          entry = Entry.new
          extract_codes(entry_element, entry)
          extract_dates(entry_element, entry)
          extract_value(entry_element, entry)
          if @status_xpath
            extract_status(entry_element, entry)
          end
          if entry.usable?
            entry_list << entry
          end
        end
        entry_list
      end

      private

      def extract_status(parent_element, entry)
        status_element = parent_element.at_xpath(@status_xpath)
        if status_element
          case status_element['code']
          when '55561003'
            entry.status = :active
          when '73425007'
            entry.status = :inactive
          when '413322009'
            entry.status = :resolved
          end
        end
      end

      def extract_codes(parent_element, entry)
        code_elements = parent_element.xpath(@code_xpath)
        code_elements.each do |code_element|
          add_code_if_present(code_element, entry)
          translations = code_element.xpath('cda:translation')
          translations.each do |translation|
            add_code_if_present(translation, entry)
          end
        end
      end

      def add_code_if_present(code_element, entry)
        if code_element['codeSystem'] && code_element['code']
          entry.add_code(code_element['code'], CodeSystemHelper.code_system_for(code_element['codeSystem']))
        end
      end

      def extract_dates(parent_element, entry)
        if parent_element.at_xpath('cda:effectiveTime')
          entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime')['value'])
        end
        if parent_element.at_xpath('cda:effectiveTime/cda:low')
          entry.start_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:low')['value'])
        end
        if parent_element.at_xpath('cda:effectiveTime/cda:high')
          entry.end_time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:high')['value'])
        end
        if parent_element.at_xpath('cda:effectiveTime/cda:center')
          entry.time = HL7Helper.timestamp_to_integer(parent_element.at_xpath('cda:effectiveTime/cda:center')['value'])
        end
      end

      def extract_value(parent_element, entry)
        value_element = parent_element.at_xpath('cda:value')
        if value_element
          value = value_element['value']
          unit = value_element['unit']
          if value
            entry.set_value(value, unit)
          end
        end
      end
    end
  end
end
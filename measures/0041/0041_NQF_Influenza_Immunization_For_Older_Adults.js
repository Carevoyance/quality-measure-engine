function () {
  var patient = this;
  var measure = patient.measures["0041"];
  if (measure==null)
    measure={};

  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 50*year;
  var earliest_encounter = effective_date - 1*year;
  var start_flu_encounter = effective_date - 122*day;
  var end_flu_encounter = effective_date - 58*day;
  
  var population = function() {
    outpatient_encounters = inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
    other_encounters = 
      inRange(measure.encounter_prev_med_40_or_older, earliest_encounter, effective_date) +
      inRange(measure.encounter_prev_med_group, earliest_encounter, effective_date) +
      inRange(measure.encounter_prev_med_ind, earliest_encounter, effective_date) +
      inRange(measure.encounter_prev_med_other, earliest_encounter, effective_date) +
      inRange(measure.encounter_nursing, earliest_encounter, effective_date) +
      inRange(measure.encounter_nursing_discharge, earliest_encounter, effective_date);
    return (patient.birthdate<=earliest_birthdate && (outpatient_encounters>1 || other_encounters>0));
  }
  
  var denominator = function() {
    flu_encounters = 
      inRange(measure.encounter_outpatient, start_flu_encounter, end_flu_encounter) + 
      inRange(measure.encounter_prev_med_40_or_older, start_flu_encounter, end_flu_encounter) + 
      inRange(measure.encounter_prev_med_group, start_flu_encounter, end_flu_encounter) + 
      inRange(measure.encounter_prev_med_ind, start_flu_encounter, end_flu_encounter) + 
      inRange(measure.encounter_prev_med_other, start_flu_encounter, end_flu_encounter) + 
      inRange(measure.encounter_nursing, start_flu_encounter, end_flu_encounter) + 
      inRange(measure.encounter_nursing_discharge, start_flu_encounter, end_flu_encounter); 
    return (flu_encounters>0);
  }
  
  var numerator = function() {
    // should this be start_flu -> end_flu instead ?
    return inRange(measure.immunization, earliest_encounter, effective_date);
  }
  
  var exclusion = function() {
    return measure.allergy_to_eggs ||
      measure.immunization_allergy ||
      measure.immunization_adverse_event ||
      measure.immunization_intolerance ||
      measure.immunization_containdication ||
      measure.immunization_declined ||
      measure.patient_reason ||
      measure.medical_reason ||
      measure.system_reason;
  }
  
  map(population, denominator, numerator, exclusion);
};

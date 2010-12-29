// Adds diabetes utility functions to the root JS object. These are then
// available for use by the supporting map-reduce functions for any measure
// that needs common definitions of diabetes-specific algorithms.
//
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  root.has_medications_indicative_of_diabetes = function(measure, earliest_diagnosis, effective_date) {
    return inRange(measure.medications_indicative_of_diabetes, earliest_diagnosis, effective_date);
  }

  root.diabetes_population = function(patient, earliest_birthdate, latest_birthdate) {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  root.diabetes_denominator = function(measure, earliest_diagnosis, effective_date) {
    diagnosis_diabetes =            inRange(measure.diagnosis_diabetes, earliest_diagnosis, effective_date);
    encounter_acute_inpatient =     inRange(measure.encounter_acute_inpatient, earliest_diagnosis, effective_date);
    encounter_non_acute_inpatient = inRange(measure.encounter_non_acute_inpatient, earliest_diagnosis, effective_date);
    return (has_medications_indicative_of_diabetes(measure, earliest_diagnosis, effective_date) 
            || 
            (diagnosis_diabetes && (encounter_acute_inpatient || encounter_non_acute_inpatient == 2)));
  }

  root.diabetes_exclusions = function(measure, earliest_diagnosis, effective_date) {
    diagnosis_gestational_diabetes =        inRange(measure.diagnosis_gestational_diabetes, earliest_diagnosis, effective_date);
    diagnosis_steroid_induced_diabetes =    inRange(measure.diagnosis_steroid_induced_diabetes, earliest_diagnosis, effective_date);
    return ((measure.polycystic_ovaries && !(diagnosis_diabetes && (encounter_acute_inpatient || encounter_non_acute_inpatient)))
            ||
            ((diagnosis_gestational_diabetes || diagnosis_steroid_induced_diabetes) 
             && has_medications_indicative_of_diabetes(measure, earliest_diagnosis, effective_date) 
             && !(diagnosis_diabetes && (encounter_acute_inpatient || encounter_non_acute_inpatient))));
  };

})();
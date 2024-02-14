# MICA/OPAL Format

The Format is based on the Microsoft Excel Format. It needs two well-defined sheets.
The first sheet needs to be named `Variables` and describes the Variables of a Data Dictionary.
The second is named `Categories` and is used to link and describe the categories of nominal and ordinal variables.

## `Variables`

`Variables` is used to describe variables of a dataset, code book, data dictionary or questionnaire. If the variable is categorical the sheet `Categories` can be used to describe the catefories.
The sheet `Variables` must have the columns:

- `table`
- `name` (mandatory)
- `valueType`
- `entityType`
- `unit`
- `mimeType`
- `repeatable`
- `occurrenceGroup`
- `referencedEntityType`
- `index`
- `label`
- `alias`

Each row of the sheet describes one variable. Some cells are optional can thus can be left empty. The properties `table` 
is used to associate a variable to a data collection element (e.g. dataset, code book, data dictionary or questionnaire ).  
If no `table` information is given the default `Table` is used, i.e. `table` is an optional property. 

- `name`                    refers to how the variable is encoded within a dataset (i.e. column name) 
- `label`                   Label, a human-readable representation of the variable. 	
- `alias`                   Alternative name for the variable, usually used for defining a shorter name for the variable.

- `valueType`	            The value type of the variable. Default value is `text`. Possible values are: `binary`, `boolean`, `datetime`, `date`, `decimal`, `integer`, `linestring`, `locale`, `point`, `polygon` and `text`.
- `referencedEntityType`	@TODO: List of possible values unknown an effect unclear!) If the variable values are entity identifiers, this is the type of the entities that are referenced
- `mimeType`	            The mime type of the variable to help applications to display documents (e.g. `image/jpeg`, `application/excel` ...). cf. https://www.iana.org/assignments/media-types/media-types.xhtml
- `entityType` 	            (@TODO: List of possible values unknown and effect unclear!)????Opal can store data on different entities such as `Participant`, `Instrument`, `Area`, `Drug`, etc. Default value is `Participant`.
- `unit`	                (@TODO: Possible values and effed unclear!)The unit in which values expressed (e.g. `cm`, `kg` ...).

- `index`                   Position or weight of the variable in the list of variables of the table for ordering. Positive integers are allowed. Default value is `0`.
- `repeatable`	            (@TODO: Meaning unclear!)`1` if repeatable, `0` if not. (eg. Three measures of blood pressure). Default value is `0`.
- `occurrenceGroup`	        (@TODO: Meaning unclear!)Name of a repeatable variable group (e.g The group [measure value, measure date] is a group of variables that can be repeated)

Additionally, the following columns can be provided to encode maelstrom taxonomy classifications. 

- `Mlstr_additional::Source`  Encode "Source" according to  [Maelstrom Additional Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AdditionalInformation.yml)
- `Mlstr_additional::Target`  Encode "Target" according to  [Maelstrom Additional Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AdditionalInformation.yml)


- `Mlstr_area::Sociodemographic_economic_characteristics`  Encode "Socio-demographic and economic characteristics" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Lifestyle_behaviours`  Encode "Lifestyle_behaviours" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Reproduction`  Encode "Birth, pregnancy and reproductive health history" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Health_status_functional_limitations`  Encode "Perception of health, quality of life, development and functional limitations" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Diseases`  Encode "Diseases" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Symptoms_signs`  Encode "Symptoms and signs" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Medication_supplements`  Encode "Medication and supplements" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Non_pharmacological_interventions`  Encode "Non-pharmacological interventions" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Health_community_care_utilization`  Encode "Health and community care services utilization" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::End_of_life`  Encode "Death" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Physical_measures`  Encode "Physical measures and assessments" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Laboratory_measures`  Encode "Laboratory measures" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Cognitive_psychological_measures`  Encode "Cognition, personality and psychological measures and assessments" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Life_events_plans_beliefs`  Encode "Life events, life plans, beliefs and values" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Preschool_school_work`  Encode "Preschool, school and work lifes" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Social_environment`  Encode "Social environment and relationships" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Physical_environment`  Encode "Physical environment" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)
- `Mlstr_area::Administrative_information`  Encode "Administrative information" according to  [Maelstrom Area of Information Taxonomy](https://github.com/maelstrom-research/maelstrom-taxonomies/blob/master/AreaOfInformation.yml)





## `Categories`

`Categories` is used to link and describe the categories of nominal and ordinal variables. The sheet `Categories` must
have the columns:

- `table` 	 
- `variable`  (mandatory)
- `name`      (mandatory)
- `missing`  
- `label`  

Each row of the sheet represent one category of a categorical variable. Some cells are optional can thus can be left empty. 
The properties `table` and `variable` are used to associate a variable defined in `Variables` sheet with the category 
definition of this sheet.  If no `table` information is given the default `Table` is used, i.e. `table` is an optional property. 

- `name` refers to the value how the category is encoded within a dataset. 
- `label` refers to the label, a human-readable representation of the category. 	
- `missing` indicates with `1` that this category is considered a missing value  (e.g. 'Don't know', 'Prefer not to answer'). The default value is `0`, which indicated that is a normal variable.  


Consider the example: a variable `sex` with categories `male`, `female` and `unknown`, where `male` is encoded as `0`, `female` as `1` and `unknown` as `-1`. 
A possible encoded is the following: 

| Table | Variable | name | missing | label   |
|-------|----------|------|---------|---------|
|       | sex      | -1   | 1       | unknown |
|       | sex      | 0    | 0       | male    |
|       | sex      | 1    |         | female  |


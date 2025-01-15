# Brief assignement steps

1. Design and develop a NoSQL data store to support a large scale application at your choice;
2. Semantically model (a portion of) the selected domain  and query the resulting ontology through SPARQL.

# More in details

1. Propose a domain you are interested in and a relevant application for it (e.g.,e-commerce domain, shopping cart and session data management application); 
2. Provide details about the nature of the proposed application (e.g., the application is read/write intensive, requires batch processing, ...), according to what discussed in the course and corresponding system requirements (e.g., eventual/strong consistency needed, high availability needed);
3. Design a conceptual schema for the identified domain. The schema should include at least three associations;
4. Identify a workload, i.e., a set of relevant and frequent operations, related to the chosen application. The workload should contain at least 5 structurally different operations. Describe each workload operation in natural language;
5. Use the aggregate-oriented design methodology (STEP 1-2-3) to design a set of aggregates for the domain and the workload at hand;
6. Design in MongoDB:
    * Design a schema for MongoDB (including partition keys and indexes), starting from (step 5), using the approaches/methodologies proposed in the course.
    * Specify each operation of the workload in the language supported by MongoDB 
7. Design in Cassandra
    * Design a schema for Cassandra  (including partition keys and indexes), starting from (step 5), using the approaches/methodologies proposed in the course.
    * Specify in CQL each operation of the workload.
8. Design in Neo4J
    * Design a schema for Neo4j, using the approaches/methodologies proposed in the course.
    * Specify in Neo4j each operation of the workload.
9. Discuss which, among the three systems, is the most suitable to be used as  back-end for your application. Motivate your choice, taking into account the features of your application (step 2) and the identified workload (step 4). Let S be the selected system;
10. Provide details about the system configuration needed in system S  for storing/processing your data according to the chosen application;
11. Create the logical schema in system S;
12. Create an instance of your schema in the selected system, according to the logical schema just created. To this aim:
    * You can use either an already available dataset or a synthetic one but we encourage the first option (it might be difficult to synthetically generate a relevant dataset for your reference application). The dataset should have a reasonable size (few Mb). 
    * Notice that selected datasets might need to be transformed in order to be used by your application. For dataset transformation, you can rely on either data transformation tools, such as Tableaux Prep (www.tableau.com), Apache Superset (superset.apache.org) Trifacta ( www.trifacta.com ), or other ETL tools such as Talend ( www.talend.com ), or scripts in your favorite language. 
    * For importing datasets in the chosen system, you should refer to the available documentation for the system you have selected (e.g. https://www.datastax.com/dev/blog/simple-data-importing-and-exporting-with-cassandra for Cassandra and https://neo4j.com/developer/guide-importing-data-and-etl/perneo4J for Neo4J).
13. Implement the workload in system S;
14. Model in RDFS / OWL the main classes and the main properties corresponding to the entities and associations in the conceptual schema (step 3). In addition:
    * For each property, specify the corresponding domain and range.
    * Express which classes are equivalent and which ones are disjoint.
    * Specify (or add) at least an inverse property.
    * For all the modeled properties, specify whether they are functional (or inverse functional).
15. Model in RDF some instances  to populate your schema. In addition:
    * Relate instances to the corresponding class or property.
    * Clarify which individuals are identical and which ones are different.
16. Specify in SPARQL at least 3 queries to be executed over the defined RDF dataset. The requests should:
    * be structurally different (i.e., each of them should contain different constructs)
    * include at least one CONSTRUCT query
    * refer as much as possible to the requests included in the workload specified in PART II.
17. Check the correctness of the proposed RDF dataset, extended with RDFS /OWL constraints, and of the proposed SPARQL queries using [RDF playground](http://rdfplayground.dcc.uchile.cl/) or any other RDF data store at your choice.

# Dataset description and cleaning

The first step in this process involved retrieving the raw dataset, a comprehensive record of various crimes reported across Los Angeles over the selected time frame. This data, while detailed, contained numerous discrepancies and inconsistencies that needed resolution to ensure its usability. The initial cleaning phase focused on addressing glaring issues such as negative age values, null entries in critical fields, and formatting inconsistencies across columns.


# Team members
- **Andrea Morando** (s4604844@studenti.unige.it)
- **Davide Miggiano** (s4840761@studenti.unige.it)
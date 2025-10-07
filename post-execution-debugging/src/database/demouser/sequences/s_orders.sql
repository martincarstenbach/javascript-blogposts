create sequence s_orders minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 /* start with n */ cache 100 noorder nocycle
nokeep noscale global;


-- sqlcl_snapshot {"hash":"e00c48877adcefef607d307cfce2af4d75268739","type":"SEQUENCE","name":"S_ORDERS","schemaName":"DEMOUSER","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>DEMOUSER</SCHEMA>\n   <NAME>S_ORDERS</NAME>\n   \n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>100</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}
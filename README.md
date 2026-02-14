# Strategic Retail Operations Diagnostic: Revenue & Logistics Audit

### **Executive Summary**
This diagnostic framework was engineered to audit **$15.5M in aggregate revenue** and identify an **8.2% SLA failure risk**. By quantifying the direct correlation between logistics performance and customer brand equity, this asset identifies specific areas of "Profit Leakage" within high-volume retail ecosystems.

### **Business Problem**
In scaled retail environments, logistics latency often results in high-churn "Profit Leakage" that remains undetected in top-line reporting. The challenge was to mathematically validate the impact of shipping delays on customer sentiment and establish a data-driven threshold for revenue protection.

## **Interactive Dashboard (Tableau Public]**
https://public.tableau.com/app/profile/tabassum.k/viz/StrategicGrowthHubMarketDensityandOperationalRiskAssessment/StrategicRetailOperationsProfitLeakageSLADiagnostic#1

### **Methodology**
* **Data Engineering:** Developed a multi-table architecture in PostgreSQL utilizing **Common Table Expressions (CTEs)** to ensure logical transparency and data integrity during high-volume joins.
* **Statistical Modeling:** Conducted correlation analysis in Python to isolate the relationship between delivery latency and satisfaction indices.
* **Executive Visualization:** Designed a strategic hub in Tableau to facilitate root-cause analysis across geographic and product vertical dimensions.

### **Skills Applied**
* **Advanced SQL:** Multi-layer CTE logic, complex relational joins, and window functions.
* **Analytical Modeling:** Statistical correlation and data preprocessing in Python.
* **Strategic Communication:** Translating technical diagnostics into executive action plans.

### **Results & Strategic Recommendations**
* **Performance Correlation:** Confirmed a statistically significant relationship ($P < 0.0001$) where delivery speed acts as the primary driver of 1-star reviews.
* **Geographic Risk Assessment:** Identified **São Paulo (SP)** as the market with the highest revenue density coupled with the highest operational complexity.
* **Operational Strategy:** Recommended a targeted optimization of fulfillment protocols in high-churn categories, such as **Health & Beauty**, to maintain the **4.1 satisfaction benchmark**.

### **Next Steps**
* Developing predictive alerting systems to flag potential SLA failures in the fulfillment pipeline.
* Expanding the diagnostic to incorporate return-rate impact on long-term customer lifetime value.

### **Author & Credits**
* **Author**:Tabassum K. Senior Business Data Analyst Portfolio
* **Data Source:** Olist E-commerce Ecosystem (Kaggle).
* **Tools:** PostgreSQL (pgAdmin), Python (Jupyter Notebook), Tableau Public.

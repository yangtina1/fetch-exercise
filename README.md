# Fetch Data Analytics Exercise
## I. Explore the data
Review the unstructured csv files and answer the following questions with code that supports your conclusions:
- Are there any data quality issues present?
- Are there any fields that are challenging to understand?

#### User table
It contains 100,000 user profiles, with information on account creation date, birth date, state, language, and gender.
- BIRTH_DATE: 3.7% of values are missing, with some potential errors such as 100+ years old. Around 1.3K users have a birthdate of 01/01/1970, which is likely a default value inserted under certain conditions.
- STATE: 4.8% missing
- LANGUAGE: 30.5% missing. "es-419" language can be re-labeled as "es" for consistency.
- GENDER: 5.9% missing
#### Product table
The table includes 845,552 rows with product-related data, including category hierarchies, manufacturers, brands, and barcodes.
- BARCODE: Key identifier of the products. 0.5% are missing. 
- CATEGORY_1 to CATEGORY_4: These fields represent the product categories in a hierarchical structure. Some products lack information at more detailed levels, particularly in CATEGORY_3 and CATEGORY_4.  
- MANUFACTURER and BRAND: around 27% missing
#### Transaction table
The table includes receipts scanned records from 06/12/2024 to 09/08/2024.
- BARCODE: missing for 11.5% of transactions
- Duplicated RECEIPT_ID and BARCODE combinations
- Invalid or missing values in FINAL_QUANTITY and FINAL_SALE  
My assumption is that the table is at the product level. Since users may scan one receipt with multiple product barcodes, duplicated RECEIPT_IDs are expected. However, after investigating the data, I noticed that most records have both duplicated RECEIPT_ID and BARCODE. Additionally, the FINAL_QUANTITY column contains with “zero” in string format, which is not a valid quantity. Some entries have missing values in FINAL_SALE. I performed data cleaning to keep the unique RECEIPT_ID and BARCODE pairs, and retained the valid numeric values for quantity and sale. After de-duplication, 25K entries remain.   

## II. Provide queries
Answer three of the following questions with at least one question coming from the closed-ended and one from the open-ended question set. Each question should be answered using one query.  
  
Closed-ended questions:
- What are the top 5 brands by receipts scanned among users 21 and over?  
  Among all users who scanned receipts in the transaction records, only 91 have corresponding profiles in the user table, making it challenging to conduct a thorough age-related analysis. However, since approximately 90% of the users in the user table are at least 21 years old, we can reasonably infer that the overall top brands by receipts scanned are representative of this age group, even though the majority of users in the transaction records are missing profiles. The top 5 brands are COCA-COLA, GREAT VALUE, PEPSI, EQUATE, and LAY'S.

  | BRAND  | MANUFACTURER  | purchases | 
  | ------------- | ------------- | ------------- |
  | COCA-COLA  | THE COCA-COLA COMPANY  | 527  |
  | GREAT VALUE  | WALMART INC. | 384  |
  | PEPSI  | PEPSICO | 361  |
  | EQUATE | WALMART INC.  | 341 |
  | LAY'S | PEPSICO | 324  |
  
- What are the top 5 brands by sales among users that have had their account for at least six months?  
  As most users are missing profiles, we cannot accurately determine their account tenure. Based the the available user profiles, the top 5 brands by sales among users with accounts older than 6 months are CVS, DOVE, TRIDENT, COORS LIGHT, and TRESEMMÉ. This should be taken as a reference only, given the limited user information available from those who scanned receipts.

  | BRAND  | sales  | 
  | ------------- | -------------  |
  | CVS |  72.0  |
  |DOVE  |  30.91 |
  | TRIDENT | 23.36  |
  | COORS LIGHT |  17.48 |
  | TRESEMMÉ |  14.58 |
  
- What is the percentage of sales in the Health & Wellness category by generation?  
  Similarly, due to the limited user profiles and lack of birthdate information, we can only provide a partial view of sales in the Health & Wellness category by generation. Based on the available data, the percentage of sales in this category is as follows:  
  
  | Generation | % of Health & Wellness | 
  | ------------- | -------------  |
  | Baby Boomers |  36.5%  |
  | Gen X  |  22.3%   |
  | Millennials |18.1%   |
  | Gen Z |  unknown (no sufficient data) |  
  
Open-ended questions: for these, make assumptions and clearly state them when answering the question.
- Who are Fetch’s power users?  
  To identify Fetch's power users, we can define "power users" as those who exhibit high engagement and contribute significantly to the company's revenue. These could be users who have a high number of transactions, have high total sales or frequently scan upload receipts to Fetch's app. Please refer to the attached query for the full list of users ranked by receipts scanned or sales. We can also define the frequency of purchases and receipt scans as the criteria; for instance, 28% of users scanned at least 2 receipts in three months. These users are more engaging than the others. The user information that is currently missing should be supplemented to understand the segment profile, such as their age, tenure, and shopping behaviors.   
- Which is the leading brand in the Dips & Salsa category?  
  TOSTITOS is the leading brand in this category, leading in both sales volume and number of purchases. Other notable brands include PACE, FRITOS, and MARKETSIDE.    
  By sales volume: TOSTITOS, GOOD FOODS, PACE, FRITOS, MARKETSIDE  
  By number of purchases: TOSTITOS, PACE, FRITOS, DEAN'S DAIRY DIP, MARKETSIDE  
  | BRAND  | receipts_scanned | purchases | 
  | ------------- | ------------- | ------------- |
  | TOSTITOS  | 36  | 181.23  |
  | PACE  | 24 | 85.75  |
  | FRITOS | 19 | 67.16  |
  | DEAN'S DAIRY DIP | 17  | 39.95 |
  | MARKETSIDE   | 16 | 65.22  |
  
- At what percent has Fetch grown year over year?  
  There are several ways to define “growth” of a company. The number of transactions is a good indicator, as it is tied to revenue. However, since the transaction data only covers the three months from 06/12/2024 to 09/08/2024, I am using the total user base as the primary metric. The percent growth will be calculated year over year by comparing the number of new users added annually. This is based on the assumption that all users remain active once enrolled, although this is unlikely to be the case. Growth is analyzed on a yearly basis, using the cumulative total user base at the end of each year. The number of new enrollments steadily increased until 2022, but dropped in 2023 and so far in 2024. Although the data shows that yearly new enrollments have declined, the total user base continues to grow each year due to the assumption of no churn. The most recent growth rates are +58% in 2022, +21% in 2023, and +13% year-to-date in 2024.  

## III. Communicate with stakeholders
Construct an email or slack message that is understandable to a product or business leader who is not familiar with your day-to-day work. Summarize the results of your investigation. Include:
- Key data quality issues and outstanding questions about the data
- One interesting trend in the data
- Use a finding from part 2 or come up with a new insight
- Request for action: explain what additional help, info, etc. you need to make sense of the data and resolve any outstanding issues
  
Hi [Product or business leader's name], 

Hope you are doing well. I am Tina from the Data Analytics Team. I recently completed an initial analysis based on the transaction data that covers the period from 06/12/2024 to 09/08/2024. I wanted share with you some key findings as well as discuss with you the next steps.  
  
First, there are several data qualities issues. We should reach out to the engineering team to ensure the data quality.  
- Incomplete user database: only 91 users from the transaction table can be found in the user base. To better analyze user behavior and demographics, we need the full user database.
- Duplicated transaction records and invalid quantities: Many transactions have duplicate receipt IDs with the same barcodes, and some records contain invalid quantities, such as the string “zero”.
- Missing product barcodes in some transaction records
  
Key findings and insights 
- Receipts spike on 07/01/2024: nearly 500 receipts were scanned, significantly higher than the daily range of 200-300 receipts. I would like to check if there were any specific events or promotions that happened. If not, it’s worth investigating potential data collection issues.
- While our total number of users continues to grow, the number of new enrollments has been declining over the past two years. This may indicate that the current targeted demographics are reaching saturation. There is an opportunity to explore in new customer acquisition strategies to maintain momentum and further scale the user base.
- The most popular brands by purchases are consumer goods, including Coca-cola, Pepsi, and Lay's, as well as Walmart's own brands Great Value and Equate. Given that Walmart's brands are among the top brands, it may suggest a price-conscious customer base. This could indicate an opportunity for promotions or partnerships with other value-oriented brands.  

Next steps:
- Could you please confirm how scanned receipts are tracked? I assume that the table is at the product level. I saw many duplicated receipt IDs with the same barcodes in the records. Understanding how the receipt records are structured can better help with data pre-processing. We may also need to involve the engineering team to address the data quality issue and ensure the level of detail is in place.
- Please let me know if there was any specific event that happened on 07/01/2024. 
- I am happy to help create a dashboard to track performance trends by user segment, product category, and brand. Let me know if this would be helpful, and we can discuss the requirements in more detail.
- Are there any ongoing initiatives or campaigns targeting any particular product categories or user segments? Since we have identified the top brands and categories, this could be a good opportunity to further drive user engagement. Please let me know and I will be happy to discuss further.

Thank you and I look forward to hearing from you.  
  
Best,  
Tina
  

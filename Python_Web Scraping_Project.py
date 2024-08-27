#!/usr/bin/env python
# coding: utf-8

# In[3]:


from bs4 import BeautifulSoup
import requests


# In[4]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'

page = requests.get(url)

soup = BeautifulSoup(page.text, 'html')


# In[5]:


print(soup)


# In[6]:


soup.find_all('table')[1]


# In[7]:


soup.find('table', class_ = 'wikitable sortable')


# In[43]:


table = soup.find_all('table')[0]


# In[44]:


print(table)


# In[45]:


USA_titles = table.find_all('th')


# In[46]:


USA_titles


# In[47]:


USA_table_titles = [title.text.strip() for title in USA_titles]
print(USA_table_titles)


# In[28]:


import pandas as pd 


# In[48]:


df = pd.DataFrame(columns = USA_table_titles)

df


# In[49]:


column_data = table.find_all('tr')


# In[51]:


for row in column_data[1:]:
    row_data = row.find_all('td')
    individual_row_data = [data.text.strip() for data in row_data]
    length = len(df)
    df.loc[length] = individual_row_data


# In[52]:


df


# In[55]:


df.to_csv(r'D:\01 Data Pribadi\Desktop\Projects\Python Project\USA_Companies.csv', index=False)


# In[ ]:





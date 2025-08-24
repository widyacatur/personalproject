import pandas as pd
import numpy as np
import pickle as pk

import streamlit as st

model = pk.load(open(r'C:\Users\Widya\Documents\GitHub\personalproject\Car Price Prediction\model.pkl', 'rb'))

st.header('Car Price Prediction ML Model')

cars_data = pd.read_csv(r'C:\Users\Widya\Documents\GitHub\personalproject\Car Price Prediction\Cardetails.csv')

def get_brand_name(car_name):
    car_name = car_name.split(' ')[0]
    return car_name.strip()

cars_data['name'] = cars_data['name'].apply(get_brand_name)

name = st.selectbox('Select Car Brand', cars_data['name'].unique())
year = st.slider('Select Year', int(cars_data['year'].min()), int(cars_data['year'].max()))
km_driven = st.slider('Select Kms Driven', int(cars_data['km_driven'].min()), int(cars_data['km_driven'].max()))
fuel = st.selectbox('Select Fuel Type', cars_data['fuel'].unique())
seller_type = st.selectbox('Select Seller Type', cars_data['seller_type'].unique())
transmission = st.selectbox('Select Transmission Type', cars_data['transmission'].unique())
owner = st.selectbox('Select Owner Type', cars_data['owner'].unique())
mileage = st.slider('Select Car Mileage', 0,42)
engine = st.slider('Select Engine CC', 600,5000)
max_power = st.slider('Select Max Power', 0,400)
seats = st.slider('Select Seats', int(cars_data['seats'].min()), int(cars_data['seats'].max()))

if st.button('Predict Price'):
    input_data_model = pd.DataFrame(
    [[name,year,km_driven,fuel,seller_type,transmission,owner,mileage,engine,max_power,seats]],
    columns=['name', 'year', 'km_driven', 'fuel', 'seller_type', 'transmission', 'owner', 'mileage', 'engine', 'max_power', 'seats'])
    st.write(input_data_model)
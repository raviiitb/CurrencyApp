# README

## App purpose
1. It gives the live exchange rates to one or more target currency from USD.
    You can select multiple target currencies from a select box. Also, you can choose the USD value to be interchanged in the target currencies. By default, it is 1. After choosing the currencies or amount you can click on the Get button. Then you will land to a new page where you will get the live exchange rate of inputted currencies.

2. It gives the historical exchange rates to one or more target currency from USD
    Here you can select the past date also not before than 16 years. After choosing the currencies or amount you can click on the Get button. Then you will land to a new page where you will get the historical exchange rate of inputted currencies.

3. It gives the best exchange rate and date in past 7 days for a particular currency.
    Here you have to select a target currency for which you want to know the best exchange rate in past 7 days. After clicking on Get button you will land to a new page where you can see the best exchange rate and corresponding date for a given currency.

## Implementation
I have used the free membership type of CurrencyLayer API.

## Input
You have to select the target currencies and an optional field value. For historical rates you have to enter the date from past on which you want to know the exchange rate.

## Output
1. For live exchange rate the output will be the live exchange rate of the inputted currencies from the USD

2. For historical exchange rates, you will get echange rate from the past.

3. For the best exchange rate from past 7 days, you will get the best rate and day from the past 7 days.

###### Note: Also, I have integrated a slack webhook. App also sends the relevant message to the slack for each query.

import json
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

with open("./data.json", "r") as file:
    data = json.load(file)

depths = [i for i in range(1, 9)]

time = [data[i]["time_taken"] for i in range(0, 8)]
lose_rates = [data[i]["loss_rate"] for i in range(0, 8)]
win_rates = [data[i]["win_rate"] for i in range(0, 8)]

sns.set_theme("poster", "whitegrid")

plt.title("Minimax Algorithm vs. Random Moves", fontsize=18)
plt.xlabel('AI Max Depth', fontsize=16)
plt.ylabel('Time Taken (in seconds)', fontsize=16)

sns.barplot(x=depths, y=time) # , palette=['grey', 'grey', 'grey', 'grey']
plt.show()
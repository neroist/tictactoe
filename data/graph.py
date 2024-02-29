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

sns.set_theme("poster", "darkgrid", palette="pastel")

plt.title("Minimax Algorithm vs. Random Moves", fontsize=18)
# plt.ylim(0, 375)
plt.xlabel('AI Max Depth', fontsize=16)
plt.ylabel('Lose Rate %', fontsize=16)

# palettes:
# autumn, cool, hot?, hsv, plasma, spring, vidris, winter,
# husl, hls

sns.barplot(x=depths, y=lose_rates, palette="spring")
plt.show()
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

title_size = 40
label_size = 32

sns.set_theme("poster", "darkgrid", palette="pastel")

# palettes:
# autumn, cool, hot?, hsv, plasma, spring, vidris, winter,
# husl, hls

# 1st figure, depth to time
plt.figure(1)
plt.title("Minimax Algorithm vs. Random Moves", fontsize=title_size)
# plt.ylim(0, 375)
plt.xlabel('AI Max Depth', fontsize=label_size)
plt.ylabel('Time Taken (in seconds)', fontsize=label_size)
sns.barplot(x=depths, y=time, palette="cool")

# 2nd figure, depth to lose rate
plt.figure(2)
plt.title("Minimax Algorithm vs. Random Moves", fontsize=title_size)
plt.xlabel('AI Max Depth', fontsize=label_size)
plt.ylabel('Lose Rate %', fontsize=label_size)
sns.barplot(x=depths, y=lose_rates, palette="winter")

plt.show()
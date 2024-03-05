import json
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

with open("./data.json", "r") as file:
    data = json.load(file)

depths = [i for i in range(1, 9)]
time = [data[i]["time_taken"] for i in range(0, 8)]
lose_rates = [data[i]["loss_rate"] for i in range(0, 8)]

title_size = 40/2
label_size = 32/1.5 - 2

px = 1 / plt.rcParams['figure.dpi']
fig_width = 1000 * px # conv pixels into inches -- px / dpi
fig_height = 600 * px 

sns.set_theme("talk", "darkgrid", palette="pastel")

# palettes:
# autumn, cool, hot?, hsv, plasma, spring, vidris, winter,
# husl, hls

# 1st figure, depth to time
plt.figure(1, figsize=(fig_width, fig_height))
plt.title("Minimax Algorithm vs. Random Moves", fontsize=title_size)
plt.xlabel('AI Max Depth', fontsize=label_size)
plt.ylabel('Time Taken (in seconds)', fontsize=label_size)
sns.barplot(x=depths, y=time, hue=depths, legend=False, palette="cool")

# 2nd figure, depth to lose rate
plt.figure(2, figsize=(fig_width, fig_height))
plt.title("Minimax Algorithm vs. Random Moves", fontsize=title_size)
plt.xlabel('AI Max Depth', fontsize=label_size)
plt.ylabel('Lose Rate %', fontsize=label_size)
sns.barplot(x=depths, y=lose_rates, hue=depths, legend=False, palette="winter")

plt.show()
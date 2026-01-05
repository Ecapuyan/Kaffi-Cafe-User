import pandas as pd
import json
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics.pairwise import cosine_similarity
import os

# Define drinks and food items
DRINKS = [
    'Caramel Macchiato', 'Cloud Biscoff', 'Cloud Matcha',
    'Cloud Strawberry', 'Kaffi Mocha', 'Matcha', 'Okinawa', 'Signature Chocolate',
    'Sweet Iced Americano', 'Vanilla Latte'
]

FOOD = [
    'Affogato Caramel', 'Basque Burnt Cheesecake', 'Butter Toast', 'Chicken Alfredo', 'Chocolate Mouse',
    'Croissant', 'Egg & Bacon Sandwich', 'Egg & Bacono', 'Ham & Cheese', 'Pancake', 'S\'mores'
]

def load_and_process_data(file_path='Collections/orders-1764772405.csv'):
    """Loads order data and creates a user-item interaction matrix."""
    try:
        orders_df = pd.read_csv(file_path)
    except FileNotFoundError:
        print(f"{file_path} not found.")
        return None

    user_item_data = []
    for index, row in orders_df.iterrows():
        try:
            items = json.loads(row['items'].replace('""', '"'))
            user = row['userId']
            for item in items:
                user_item_data.append({'user': user, 'item': item['name']})
        except (json.JSONDecodeError, TypeError):
            continue

    if not user_item_data:
        print("No valid item data could be extracted from orders.")
        return None

    user_item_df = pd.DataFrame(user_item_data)
    interaction_matrix = pd.crosstab(user_item_df['user'], user_item_df['item'])
    interaction_matrix[interaction_matrix > 0] = 1
    return interaction_matrix

def calculate_similarity(interaction_matrix):
    """Calculates the cosine similarity between all items."""
    if interaction_matrix is None or interaction_matrix.empty:
        return None
    similarity_matrix = cosine_similarity(interaction_matrix.T)
    similarity_df = pd.DataFrame(similarity_matrix, index=interaction_matrix.columns, columns=interaction_matrix.columns)
    return similarity_df

def export_knn_data(interaction_matrix, similarity_df):
    """Exports the item-user matrix, full similarity matrix, and top similarities per drink to a CSV file."""
    if interaction_matrix is None or similarity_df is None:
        print("Cannot export KNN data due to missing matrices.")
        return

    item_user_matrix = interaction_matrix.T
    full_similarity_df = similarity_df * 100

    with open('knn_visual_data.csv', 'w') as f:
        f.write('--- Raw User-Item Interaction Matrix ---\n')
        f.write('This matrix shows which users (columns) purchased which items (rows). 1 means a purchase was made.\n\n')
        item_user_matrix.to_csv(f)

        f.write('\n\n--- Full Raw Item-to-Item Similarity Matrix (%) ---\n')
        f.write('This matrix shows the co-purchase similarity between every pair of items.\n\n')
        full_similarity_df.to_csv(f, float_format='%.2f')
        
        f.write('\n\n--- Top Similar Items for Each Drink (Raw Scores) ---\n')
        f.write('For each drink, this section lists all other items sorted by similarity score in descending order.\n\n')
        
        valid_drinks = [d for d in DRINKS if d in similarity_df.index]
        
        for drink in valid_drinks:
            # Get similarities for the current drink against all items
            drink_similarities = similarity_df.loc[drink].drop(drink) # Drop self-similarity
            
            # Sort by similarity score
            top_items = drink_similarities.sort_values(ascending=False)
            
            # Format for CSV
            f.write(f'"{drink}" Similarities:\n')
            top_items_df = pd.DataFrame({'Similarity': top_items})
            top_items_df.index.name = 'Item'
            top_items_df.to_csv(f, float_format='%.4f')
            f.write('\n')
            
    print("knn_visual_data.csv updated with full data.")

def generate_drink_food_heatmap(similarity_df):
    """Generates a heatmap showing similarity between drinks (y-axis) and food (x-axis)."""
    if similarity_df is None:
        return

    drink_items = [item for item in DRINKS if item in similarity_df.index]
    food_items = [item for item in FOOD if item in similarity_df.columns]
    
    if not drink_items or not food_items:
        print("Not enough drink or food items to generate a drink-food heatmap.")
        return

    # Create the specific drink-food similarity matrix
    drink_food_similarity = similarity_df.loc[drink_items, food_items] * 100

    plt.figure(figsize=(18, 10))
    sns.heatmap(drink_food_similarity, cmap='YlGnBu', annot=True, fmt=".0f", linewidths=.5, linecolor='black')
    plt.title('Co-purchase Similarity between Drinks and Food Items (%)')
    plt.ylabel('Drinks')
    plt.xlabel('Food Items')
    plt.tight_layout()
    plt.savefig('knn_full_similarity_heatmap.png')
    plt.close()
    print("knn_full_similarity_heatmap.png updated.")

def generate_top_n_drinks_heatmap(similarity_df, n=5):
    """Generates a heatmap showing the top N most similar drinks for each drink."""
    if similarity_df is None:
        return

    drink_similarity_df = similarity_df.loc[similarity_df.index.isin(DRINKS), similarity_df.columns.isin(DRINKS)]
    
    top_n_similarities = pd.DataFrame(index=drink_similarity_df.index, columns=drink_similarity_df.columns)

    for item in drink_similarity_df.index:
        top_n_items = drink_similarity_df.loc[item].nlargest(n + 1).index # +1 to include self
        for col in drink_similarity_df.columns:
            if col in top_n_items:
                top_n_similarities.loc[item, col] = drink_similarity_df.loc[item, col]

    top_n_similarities = top_n_similarities.dropna(how='all').dropna(axis=1, how='all')
    top_n_similarities = top_n_similarities.fillna(0) * 100

    plt.figure(figsize=(14, 10))
    sns.heatmap(top_n_similarities, cmap='YlGnBu', annot=True, fmt=".0f", linewidths=.5, linecolor='black')
    plt.title(f'Top {n} Most Similar Drinks (Co-purchase Similarity %)')
    plt.xlabel('Similar Drinks')
    plt.ylabel('Base Drink')
    plt.tight_layout()
    plt.savefig('knn_top_5_drinks_heatmap.png')
    plt.close()
    print("knn_top_5_drinks_heatmap.png generated.")

def generate_similarity_bar_charts(similarity_df, n=5):
    """For each drink, generates a bar chart of its top N similar food items."""
    if similarity_df is None:
        return

    output_dir = 'similarity_bar_charts'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Get a list of drinks and food that are actually in the similarity matrix
    valid_drinks = [d for d in DRINKS if d in similarity_df.index]
    valid_food = [f for f in FOOD if f in similarity_df.columns]

    if not valid_drinks or not valid_food:
        print("Not enough drink or food items to generate similarity bar charts.")
        return

    for drink in valid_drinks:
        # For the current drink, get similarities to all valid food items
        food_similarities = similarity_df.loc[drink, valid_food]
        
        # Get the top N food items
        top_n = food_similarities.nlargest(n) * 100
        
        if top_n.empty:
            continue

        plt.figure(figsize=(10, 7))
        sns.barplot(x=top_n.values, y=top_n.index, palette='Greens_r')
        plt.title(f'Top {n} Food Recommendations for "{drink}"')
        plt.xlabel('Recommendation Strength (%)')
        plt.ylabel('Food Item')
        plt.xlim(0, max(100, top_n.max() * 1.1)) # Adjust x-axis limit
        
        # Sanitize filename
        safe_filename = "".join([c for c in drink if c.isalpha() or c.isdigit() or c==' ']).rstrip()
        plt.savefig(os.path.join(output_dir, f'{safe_filename}_food_recommendations.png'))
        plt.close()

    print(f"Food recommendation bar charts generated in '{output_dir}' directory.")


def generate_user_matrix_and_recommendations(interaction_matrix, similarity_df):
    """Generates a visual for the user-item matrix and prints recommendations."""
    if interaction_matrix is None or similarity_df is None:
        return

    # 1. Load user data and create mapping
    try:
        users_df = pd.read_csv('Collections/users-1764584967.csv')
        # Use email as fallback if __id__ is missing, then keep original id
        users_df['id_col'] = users_df['__id__'].fillna(users_df['email'])
        user_map = users_df.set_index('id_col')['name'].to_dict()
    except FileNotFoundError:
        print("Users CSV not found. Cannot map IDs to names.")
        user_map = {}

    # 2. Create the user-item matrix with names
    user_item_matrix_named = interaction_matrix.copy()
    user_item_matrix_named.index = user_item_matrix_named.index.map(lambda x: user_map.get(x, x))
    
    # Sort by item popularity and user purchase count for a cleaner visual
    sorted_items = user_item_matrix_named.sum().sort_values(ascending=False).index
    user_item_matrix_sorted = user_item_matrix_named[sorted_items]
    user_item_matrix_sorted = user_item_matrix_sorted.loc[user_item_matrix_sorted.sum(axis=1).sort_values(ascending=False).index]


    # 3. Generate and save the visual as a table
    # Increase figsize and set table scale to 1.5 for larger sections as per user request
    fig, ax = plt.subplots(figsize=(user_item_matrix_sorted.shape[1] * 1.5, user_item_matrix_sorted.shape[0] * 1.5)) # Large figure size
    ax.set_title('User-Item Purchase Matrix (1 = Purchased)', loc='center', fontsize=22, pad=50) # Increased title font and padding
    ax.axis('off') # Hide axes

    table_data = user_item_matrix_sorted.values
    col_labels = user_item_matrix_sorted.columns
    row_labels = user_item_matrix_sorted.index

    table = ax.table(cellText=table_data,
                     rowLabels=row_labels,
                     colLabels=col_labels,
                     cellLoc='center',
                     loc='center')

    table.auto_set_font_size(False)
    table.set_fontsize(16) # Larger font for table content
    table.auto_set_column_width(col=list(range(len(col_labels))))
    table.scale(1.5, 1.5) # Set scale to 1.5 as requested

    # Style header
    for (i, j), cell in table.get_celld().items():
        if i == 0: # Header row
            cell.set_text_props(weight='bold', rotation=90)
            cell.set_facecolor('#D3D3D3') # Light grey background
            cell.set_fontsize(14) # Header font size
        elif j == -1: # Row labels
            cell.set_text_props(weight='bold')
            cell.set_facecolor('#D3D3D3') # Light grey background
            cell.set_fontsize(14) # Row label font size

    plt.tight_layout(pad=5.0)
    plt.savefig('user_item_matrix.png', dpi=300) # Keep high DPI
    plt.close()
    print("user_item_matrix.png generated as a table.")

    # 4. Print the raw data matrix to console
    print("\n\n" + "="*50)
    print("        Raw User-Item Purchase Matrix")
    print("="*50)
    # To prevent huge output, we'll only show users who bought something
    # and items that were bought by at least one person.
    relevant_matrix = interaction_matrix.loc[:, interaction_matrix.sum(axis=0) > 0]
    relevant_matrix = relevant_matrix.loc[relevant_matrix.sum(axis=1) > 0]
    print(relevant_matrix)


    # 5. Print the top 5 food recommendations for each drink
    print("\n\n" + "="*50)
    print("    Top 5 Food Recommendations for Each Drink")
    print("="*50)
    valid_drinks = [d for d in DRINKS if d in similarity_df.index]
    valid_food = [f for f in FOOD if f in similarity_df.columns]

    for drink in valid_drinks:
        food_similarities = similarity_df.loc[drink, valid_food]
        top_5_food = food_similarities.nlargest(5)
        
        print(f"\n--- {drink} ---")
        if top_5_food.empty:
            print("No food recommendations available.")
        else:
            for food_item, score in top_5_food.items():
                print(f"  - {food_item} (Similarity: {score:.0%})")
    print("\n" + "="*50)


if __name__ == "__main__":
    try:
        interaction_matrix = load_and_process_data()
        if interaction_matrix is not None:
            similarity_df = calculate_similarity(interaction_matrix)
            
            if similarity_df is not None:
                # Export data file
                export_knn_data(interaction_matrix, similarity_df)
                
                # Generate Visuals
                generate_drink_food_heatmap(similarity_df)
                generate_top_n_drinks_heatmap(similarity_df, n=5)
                generate_similarity_bar_charts(similarity_df, n=5)

                # Generate new report and visual
                generate_user_matrix_and_recommendations(interaction_matrix, similarity_df)
                
                print("\nAll KNN data and visuals have been updated.")
    except ImportError:
        print("Could not generate visuals because pandas, matplotlib, seaborn, or scikit-learn is not installed.")
        print("Please install them using: pip install pandas matplotlib seaborn scikit-learn")
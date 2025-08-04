class Nutrients:
    def __init__(self):
        self.nutrient_level = 0  # Initialize nutrient level

    def add_nutrients(self, amount):
        """Add nutrients to the system."""
        self.nutrient_level += amount
        print(f"Nutrients added: {amount}. Current nutrient level: {self.nutrient_level}")

    def check_nutrient_levels(self):
        """Check the current nutrient levels."""
        return self.nutrient_level
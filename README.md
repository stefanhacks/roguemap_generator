<p align="center">
  <img src="https://github.com/user-attachments/assets/fd4a5c58-9a14-4f27-b53e-a361fba9f18f" />
</p>

# Godot Roguelike Map Generator
###### Mostly everything is of my own doing, including the ugly bits.

---

### Room algo works by:
- First splits the screen in three zones with variable horizontal and vertical sizes.
- Merges one to three cells.
- Randomizes horizontal lines which contain no merges.
- Cuts out some of the areas for variety.
- Creates a square room of variable size and point inside each space.
- Possibly adds extra walls to each corner of each room to make it look a bit more organic.

### Pathways generated by:
- Shuffles the list of rooms.
- Selects two random rooms.
- Selects if pathway is going to be a simple corner or a have a short lengthy segment in between.
- Has a method which connects all rooms by iterating through a shuffled list. This ensures all rooms are connected at least once.

### Graphics:
- Original Tileset got from [Pìxel Poem, on itch.io](https://pixel-poem.itch.io/dungeon-assetpuck).
- In order to understand Godot Tileset terrains, I had to change a bit and expand in some of its options.

### Shortcomings:
- Tileset has repeated graphics. The reason for this is so I can compare the pathways from the Terrain editor with Godot's Documentation with less hassle.
- Implementation might not be the most optimal one, I relied only on my own code and experience to implement this.

// Initial array
let list = ["Item 1", "Item 2", "Item 3"];
console.log("Initial array:", list);
// CREATE: Add an item
list.push("Item 4");
console.log("After CREATE (added Item 4):", list);
// READ: Display all items
console.log("READ - All items:");
list.forEach((item, index) => {
  console.log(`Index ${index}: ${item}`);
});
// READ: Access a specific item (Example - second item)
console.log("READ - Second item:", list[1]);
// UPDATE: Change second item (index 1)
list[1] = "Item 2 (updated)";
console.log("After UPDATE (changed Item 2):", list);
// UPDATE: Use map to update all items (Example - add ' (Updated)' to every item)
list = list.map(item => `${item} (Updated)`);
console.log("After UPDATE (all items updated):", list);
// DELETE: Remove the third item (index 2)
list.splice(2, 1);
console.log("After DELETE (removed index 2):", list);
// DELETE: Remove all items containing the word "Item"
list = list.filter(item => !item.includes("Item"));
console.log("After DELETE (removed all 'Item' entries):", list);
// FIND: Locate the first item that contains 'updated'
const foundItem = list.find(item => item.includes("updated"));
console.log("FIND - First item that includes 'updated':", foundItem);
// SORT: Sort the items alphabetically
list.sort();
console.log("After SORT (alphabetical order):", list);
// REVERSE: Reverse the order of the items
list.reverse();
console.log("After REVERSE (array reversed):", list);
// CLEAR: Clear the array
list.length = 0;
console.log("After CLEAR (array cleared):", list);
// Final array after all operations
console.log("Final array:", list);

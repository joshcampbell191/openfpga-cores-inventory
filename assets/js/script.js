$(document).ready(function() {
  $('.datatable').DataTable({
    fixedHeader: true,
    info: false,
    paging: false,
    columnDefs: [
      { targets: 'no-sort', orderable: false }
    ]
  });
});

$(document).ready(function() {
  const datatable = document.querySelector(".dataTables_wrapper")
  datatable.insertAdjacentHTML("afterbegin", `<div class="filters"></div>`)
  let filters = new Set()
  const container = document.querySelector(".filters");
  const table = document.querySelector(".datatable");
  const rows = table.querySelectorAll("tbody tr");
  const data = [...rows].map(row => row.dataset.category);
  const set = new Set(data)
  set.delete("")
  const categories = [...set].sort()

  categories.forEach(category => {
    container.insertAdjacentHTML("beforeend", `<div class="md-chip md-chip-clickable" data-filter="${category}">${category}</div>`)
  })

  function applyFilter(chip) {
    let category = chip.dataset.filter;

    if (chip.classList.contains("active")) {
      filters.delete(category)
      chip.classList.remove("active")
      chip.querySelector(".md-chip-remove").remove()

      rows.forEach(row => {
        if (!filters.has(row.dataset.category)) {
          row.style.display = "table-row";
        }
      })
    } else {
      filters.add(category)
      chip.classList.add("active")
      chip.insertAdjacentHTML("beforeend", `<button type="button" class="md-chip-remove">`)

      rows.forEach(row => {
        if (filters.has(row.dataset.category)) {
          row.style.display = "table-row";
        } else {
          row.style.display = "none";
        }
      })
    }
  }

  document.querySelectorAll(".md-chip-clickable").forEach(chip => {
    chip.addEventListener("click", () => applyFilter(chip))
  })
});

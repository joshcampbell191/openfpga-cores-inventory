var filters = new Set()

function initializeDatatables() {
  $(".datatable").DataTable({
    fixedHeader: true,
    info: false,
    paging: false,
    scrollX: true,
    language: {
      search: "",
      searchPlaceholder: "Search cores"
    }
  });
}

function addFilter(chip, rows) {
  filters.add(chip.dataset.filterValue)
  chip.classList.add("active")
  chip.insertAdjacentHTML("afterbegin", `<div class="md-chip-remove"><img src="assets/images/check.svg"></div>`)

  rows.forEach(row => {
    if (filters.has(row.dataset.category)) {
      row.style.display = "table-row";
    } else {
      row.style.display = "none";
    }
  })
}

function removeFilter(chip, rows) {
  filters.delete(chip.dataset.filterValue)
  chip.classList.remove("active")
  chip.querySelector(".md-chip-remove").remove()

  rows.forEach(row => {
    if (!filters.has(row.dataset.category)) {
      row.style.display = "table-row";
    }
  })
}

function applyFilter(chip, rows) {
  chip.classList.contains("active") ? removeFilter(chip, rows) : addFilter(chip, rows)
}

$(document).ready(function() {
  const table = document.querySelector(".datatable");
  const rows = table.querySelectorAll("tbody tr");
  const data = [...rows].filter(row => row.dataset.category !== "").map(row => row.dataset.category).sort()
  const categories = [...new Set(data)]

  initializeDatatables()

  const datatable = document.querySelector(".dataTables_wrapper")
  datatable.insertAdjacentHTML("afterbegin", `<div class="filters"></div>`)

  const container = document.querySelector(".filters");

  categories.forEach(category => {
    container.insertAdjacentHTML("beforeend", `<div class="md-chip md-chip-clickable" data-filter-value="${category}">${category}</div>`)
  })

  document.querySelectorAll(".md-chip-clickable").forEach(chip => {
    chip.addEventListener("click", () => applyFilter(chip, rows))
  })
});

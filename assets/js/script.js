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

function applyFilter(chip, rows) {
  if (chip.classList.contains("active")) {
    filters.delete(chip.dataset.filterValue)
    chip.classList.remove("active")
    chip.querySelector(".md-chip-remove").style.display = "none"
  } else {
    filters.add(chip.dataset.filterValue)
    chip.classList.add("active")
    chip.querySelector(".md-chip-remove").style.display = "flex"
  }

  rows.forEach(row => {
    if (filters.size === 0 || filters.has(row.dataset.category)) {
      row.style.display = "table-row";
    } else {
      row.style.display = "none";
    }
  })
}

document.addEventListener("DOMContentLoaded", () => {
  const table = document.querySelector(".datatable");
  const rows = table.querySelectorAll("tbody tr");
  const data = [...rows].filter(row => row.dataset.category !== "").map(row => row.dataset.category).sort()
  const categories = [...new Set(data)]

  initializeDatatables()

  const datatable = document.querySelector(".dataTables_wrapper")
  datatable.insertAdjacentHTML("afterbegin", `<div class="filters"></div>`)

  const container = document.querySelector(".filters");

  categories.forEach(category => {
    let chip = `
      <div class="md-chip md-chip-clickable" data-filter-value="${category}">
        <div class="md-chip-remove" style="display: none;">
          <img src="assets/images/check.svg">
        </div>
        ${category}
      </div>
    `
    container.insertAdjacentHTML("beforeend", chip)
  })

  document.querySelectorAll(".md-chip").forEach(chip => {
    chip.addEventListener("click", () => applyFilter(chip, rows))
  })
})

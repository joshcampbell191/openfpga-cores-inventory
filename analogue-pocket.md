---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: Analogue Pocket
---
<script>
  function sortTable() {
    const tableBody = document.querySelector("tbody");
    const tableRows = tableBody.querySelectorAll("tr");
    [...tableRows]
      .sort((a, b) => a.innerText > b.innerText ? 1 : -1)
      .forEach(row => tableBody.appendChild(row))
  }
  document.addEventListener("DOMContentLoaded", sortTable)
</script>

The [Analogue Pocket](https://www.analogue.co/pocket) is a multi-video-game-system portable handheld designed and built by [Analogue](https://www.analogue.co).

## Cores

| Name | Platform | Author | Release | Release Date |
| ---- | -------- | ------ | ------- | ------------ |
{% for developer in site.data.cores -%}
{% for core in developer.cores -%}
| [{{ core.display_name }}](https://github.com/{{ developer.username }}/{{ core.repository }}) | {{ core.platform }} | [{{ developer.username }}](https://github.com/{{ developer.username }}) | [![release](https://img.shields.io/github/v/release/{{ developer.username }}/{{ core.repository }}?include_prereleases)](https://github.com/{{ developer.username }}/{{ core.repository }}/releases/latest) | ![GitHub Release Date](https://img.shields.io/github/release-date-pre/{{ developer.username }}/{{ core.repository }}) |
{% endfor -%}
{% endfor -%}

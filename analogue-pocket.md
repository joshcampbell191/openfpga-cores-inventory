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

| Name | Author | Release | Release Date |
| ---- | ------ | ------- | ------------ |
{% for devloper in site.data.cores -%}
{% for core in devloper.cores -%}
| [{{ core.display_name }}](https://github.com/{{ devloper.username }}/{{ core.repo }}) | [{{ devloper.username }}](https://github.com/{{ devloper.username }}) | [![release](https://img.shields.io/github/v/release/{{ devloper.username }}/{{ core.repo }}?include_prereleases)](https://github.com/{{ devloper.username }}/{{ core.project }}/releases/latest) | ![GitHub Release Date](https://img.shields.io/github/release-date-pre/{{ devloper.username }}/{{ core.repo }}) |
{% endfor -%}
{% endfor -%}

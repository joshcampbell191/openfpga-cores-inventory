---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: page
title: Analogue Pocket
---

The [Analogue Pocket](https://www.analogue.co/pocket) is a multi-video-game-system portable handheld designed and built by [Analogue](https://www.analogue.co).

## Cores

<table class="datatable">
  <thead>
    <tr>
      <th>Name</th>
      <th>Platform</th>
      <th>Author</th>
      <th>Version</th>
      <th>Date</th>
    </tr>
  </thead>
  <tbody>
    {% for developer in site.data.cores -%}
      {% for core in developer.cores -%}
        <tr>
          <td><a href="https://github.com/{{ developer.username }}/{{ core.repository }}">{{ core.display_name }}</a></td>
          <td>{{ core.platform }}</td>
          <td><a href="https://github.com/{{ developer.username }}">{{ developer.username }}</a></td>
          <td data-order="{{ core.version }}">
            <a href="https://github.com/{{ developer.username }}/{{ core.repository }}/releases/latest">
              <img src="https://img.shields.io/github/v/release/{{ developer.username }}/{{ core.repository }}?include_prereleases&label=" alt="release">
            </a>
          </td>
          <td data-order="{{ core.date_release | date: "%s" }}">
            <img src="https://img.shields.io/github/release-date-pre/{{ developer.username }}/{{ core.repository }}?label=" alt="GitHub Release Date">
          </td>
        </tr>
      {% endfor -%}
    {% endfor -%}
  </tbody>
</table>

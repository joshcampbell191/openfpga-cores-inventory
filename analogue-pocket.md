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
        {%- if core.prerelease %}
          {% assign metadata = core.prerelease %}
        {%- else %}
          {%- assign metadata = core.release %}
        {%- endif %}
        <tr>
          <td><a href="https://github.com/{{ developer.username }}/{{ core.repository }}">{{ core.display_name }}</a></td>
          <td>{{ core.platform }}</td>
          <td><a href="https://github.com/{{ developer.username }}">{{ developer.username }}</a></td>
          <td data-order="{{ metadata.tag_name | remove_first: "v" }}">            
            <a href="https://github.com/{{ developer.username }}/{{ core.repository }}/releases/latest">{{ metadata.tag_name }}</a>
          </td>
          <td data-order="{{ metadata.release_date | date: "%s" }}">
            {{ metadata.release_date | date: "%B %-d, %Y" }}
          </td>
        </tr>
      {% endfor -%}
    {% endfor -%}
  </tbody>
</table>

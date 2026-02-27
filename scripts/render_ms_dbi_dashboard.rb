#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'cgi'

ROOT = File.expand_path('..', __dir__)
INPUT_JSON = File.join(ROOT, 'data', 'ms_dbi_program_data.json')
OUTPUT_HTML = File.join(ROOT, 'ms_dbi_dashboard.html')

DATA = JSON.parse(File.read(INPUT_JSON))


def html_template(data)
  json_payload = JSON.generate(data).gsub('</', '<\/')
  <<~HTML
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>WGU MS Design for Business Innovation Dashboard</title>
      <style>
        :root {
          --bg: #f1f5f2;
          --surface: #ffffff;
          --ink: #16302b;
          --muted: #4d6b65;
          --line: #cfe0d9;
          --accent: #0f766e;
          --accent-2: #9a3412;
          --accent-3: #134e4a;
        }
        * { box-sizing: border-box; }
        body {
          margin: 0;
          font-family: "Avenir Next", "Trebuchet MS", "Segoe UI", sans-serif;
          color: var(--ink);
          background:
            radial-gradient(circle at 100% 0%, #ddeee8 0%, transparent 36%),
            radial-gradient(circle at 0% 100%, #f5eadf 0%, transparent 38%),
            var(--bg);
        }
        .wrap {
          max-width: 1600px;
          margin: 0 auto;
          padding: 20px;
        }
        .hero {
          border-radius: 16px;
          padding: 24px;
          color: #fff;
          background: linear-gradient(125deg, var(--accent-3) 0%, var(--accent) 55%, #12877f 100%);
          box-shadow: 0 12px 30px rgba(19, 78, 74, 0.25);
        }
        .hero h1 {
          margin: 0;
          font-size: 1.65rem;
          line-height: 1.2;
          letter-spacing: 0.2px;
        }
        .hero p {
          margin: 8px 0 0;
          opacity: 0.94;
          max-width: 1100px;
        }
        .kpi-grid {
          margin-top: 14px;
          display: grid;
          gap: 10px;
          grid-template-columns: repeat(5, minmax(0, 1fr));
        }
        .kpi {
          background: var(--surface);
          border: 1px solid var(--line);
          border-radius: 12px;
          padding: 10px 12px;
        }
        .kpi .k {
          font-size: 0.78rem;
          color: var(--muted);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }
        .kpi .v {
          margin-top: 3px;
          font-size: 1.3rem;
          font-weight: 700;
          color: var(--accent-3);
        }
        .tabs {
          margin-top: 14px;
          display: flex;
          gap: 8px;
          flex-wrap: wrap;
        }
        .tab-btn {
          border: 1px solid var(--line);
          background: #e7f3ef;
          color: var(--accent-3);
          padding: 8px 12px;
          border-radius: 999px;
          font-size: 0.9rem;
          font-weight: 600;
          cursor: pointer;
        }
        .tab-btn.active {
          background: var(--accent);
          color: #fff;
          border-color: var(--accent);
        }
        .panel {
          margin-top: 12px;
          border: 1px solid var(--line);
          border-radius: 14px;
          background: var(--surface);
          padding: 14px;
          display: none;
        }
        .panel.active { display: block; }
        .panel h2 {
          margin: 0 0 8px;
          font-size: 1.1rem;
          color: var(--accent-3);
        }
        .subtle {
          color: var(--muted);
          font-size: 0.92rem;
          margin-bottom: 10px;
        }
        .overview-grid {
          display: grid;
          gap: 10px;
          grid-template-columns: repeat(2, minmax(0, 1fr));
        }
        .box {
          border: 1px solid var(--line);
          border-radius: 12px;
          padding: 12px;
          background: #f9fcfb;
        }
        .box h3 {
          margin: 0 0 6px;
          font-size: 0.98rem;
          color: var(--accent-3);
        }
        .market-list {
          display: grid;
          grid-template-columns: 1fr;
          gap: 8px;
        }
        .market-item {
          border: 1px solid var(--line);
          border-radius: 10px;
          padding: 10px;
          background: #fff;
        }
        .market-item .theme {
          font-weight: 700;
          margin-bottom: 4px;
          color: var(--accent-3);
        }
        .pill {
          display: inline-block;
          padding: 2px 8px;
          border-radius: 999px;
          font-size: 0.75rem;
          border: 1px solid #e8d4c8;
          background: #fff3eb;
          color: #8c2f0a;
          margin-right: 5px;
          margin-bottom: 4px;
          white-space: nowrap;
        }
        .controls {
          display: grid;
          gap: 10px;
          grid-template-columns: 1fr 1fr 1fr 1fr auto;
          align-items: end;
          margin-bottom: 10px;
        }
        .control label {
          display: block;
          font-size: 0.78rem;
          color: var(--muted);
          margin-bottom: 4px;
        }
        input, select, button {
          width: 100%;
          padding: 8px 9px;
          border-radius: 8px;
          border: 1px solid var(--line);
          font-size: 0.9rem;
          background: #fff;
        }
        button {
          cursor: pointer;
          border: none;
          font-weight: 600;
          background: var(--accent-2);
          color: #fff;
        }
        .table-wrap {
          border: 1px solid var(--line);
          border-radius: 12px;
          overflow: auto;
          max-height: 70vh;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          min-width: 1200px;
        }
        th {
          text-align: left;
          position: sticky;
          top: 0;
          z-index: 1;
          background: #edf5f2;
          color: #244740;
          border-bottom: 1px solid var(--line);
          padding: 9px;
          font-size: 0.8rem;
        }
        td {
          border-bottom: 1px solid var(--line);
          vertical-align: top;
          padding: 9px;
          font-size: 0.88rem;
          line-height: 1.35;
        }
        tr:hover td { background: #f6faf8; }
        a { color: #0f766e; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .agent-grid {
          display: grid;
          grid-template-columns: repeat(2, minmax(0, 1fr));
          gap: 10px;
        }
        .agent-card {
          border: 1px solid var(--line);
          border-radius: 12px;
          padding: 12px;
          background: #fff;
        }
        .agent-card h3 {
          margin: 0 0 6px;
          color: var(--accent-3);
          font-size: 0.98rem;
        }
        .agent-card p {
          margin: 0 0 6px;
          font-size: 0.88rem;
        }
        .foot {
          margin-top: 10px;
          color: var(--muted);
          font-size: 0.82rem;
        }
        @media (max-width: 1150px) {
          .kpi-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
          .overview-grid { grid-template-columns: 1fr; }
          .controls { grid-template-columns: 1fr; }
          .agent-grid { grid-template-columns: 1fr; }
        }
      </style>
    </head>
    <body>
      <div class="wrap">
        <section class="hero">
          <h1>WGU MS Design for Business Innovation Dashboard</h1>
          <p>Interactive program blueprint for a competency-based, fully online master's model with AI-Enabled Human-Centered Design Studio, embedded Agentic AI certificate, course architecture, and market alignment evidence.</p>
        </section>

        <section class="kpi-grid">
          <div class="kpi"><div class="k">Courses</div><div class="v" id="kpiCourses">0</div></div>
          <div class="kpi"><div class="k">Total Competencies</div><div class="v" id="kpiCompetencies">0</div></div>
          <div class="kpi"><div class="k">Skills Library</div><div class="v" id="kpiSkills">0</div></div>
          <div class="kpi"><div class="k">Program Tasks</div><div class="v" id="kpiTasks">0</div></div>
          <div class="kpi"><div class="k">Embedded Cert Courses</div><div class="v" id="kpiCertCourses">0</div></div>
        </section>

        <section class="tabs">
          <button class="tab-btn active" data-tab="overview">Overview</button>
          <button class="tab-btn" data-tab="courses">Course Layout</button>
          <button class="tab-btn" data-tab="skills">Skills Library</button>
          <button class="tab-btn" data-tab="competition">Competitive Analysis</button>
          <button class="tab-btn" data-tab="sources">Sources</button>
        </section>

        <section class="panel active" id="panel-overview">
          <h2>Program Snapshot</h2>
          <div class="subtle">Credential: <span id="programName"></span> | Modality: <span id="programModality"></span> | Duration: <span id="programDuration"></span> months | Embedded Certificate: <span id="embeddedCert"></span><span id="agentLibraryLink"></span></div>
          <div class="overview-grid">
            <div class="box">
              <h3>Value Proposition</h3>
              <ul id="valueList"></ul>
            </div>
            <div class="box">
              <h3>Delivery Model</h3>
              <ul id="deliveryList"></ul>
            </div>
          </div>
          <h2 style="margin-top: 14px;">Market Demand Evidence</h2>
          <div class="market-list" id="marketList"></div>
        </section>

        <section class="panel" id="panel-courses">
          <h2>Course Layout, Competencies, and Tasks</h2>
          <div class="subtle">Filter by course, section, and search terms across competencies, skills, and AI-enabled task design.</div>
          <div class="controls">
            <div class="control">
              <label for="courseFilter">Course</label>
              <select id="courseFilter"></select>
            </div>
            <div class="control">
              <label for="sectionFilter">Section</label>
              <select id="sectionFilter"></select>
            </div>
            <div class="control">
              <label for="competencyFilter">Competency</label>
              <select id="competencyFilter"></select>
            </div>
            <div class="control">
              <label for="courseSearch">Search</label>
              <input id="courseSearch" placeholder="Search tasks, deliverables, agents, skills" />
            </div>
            <div class="control">
              <label>&nbsp;</label>
              <button id="resetCourseFilters">Reset</button>
            </div>
          </div>
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Course</th>
                  <th>Section</th>
                  <th>Competencies</th>
                  <th>Section Skills</th>
                  <th>Task</th>
                  <th>AI-Enabled Flow</th>
                  <th>Deliverable</th>
                </tr>
              </thead>
              <tbody id="courseRows"></tbody>
            </table>
          </div>
        </section>

        <section class="panel" id="panel-skills">
          <h2>Skills Library</h2>
          <div class="subtle">Full skill inventory for all ten courses. Filter by course and domain.</div>
          <div class="controls" style="grid-template-columns: 1fr 1fr 1fr auto auto;">
            <div class="control">
              <label for="skillCourseFilter">Course</label>
              <select id="skillCourseFilter"></select>
            </div>
            <div class="control">
              <label for="skillDomainFilter">Domain</label>
              <select id="skillDomainFilter"></select>
            </div>
            <div class="control">
              <label for="skillSearch">Search</label>
              <input id="skillSearch" placeholder="Search skills" />
            </div>
            <div class="control">
              <label>&nbsp;</label>
              <button id="resetSkillFilters">Reset</button>
            </div>
            <div class="control">
              <label>&nbsp;</label>
              <button id="exportSkillsCsv">Export CSV</button>
            </div>
          </div>
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Skill ID</th>
                  <th>Skill</th>
                  <th>Domain</th>
                  <th>Course</th>
                </tr>
              </thead>
              <tbody id="skillsRows"></tbody>
            </table>
          </div>
        </section>

        <section class="panel" id="panel-competition">
          <h2>Competitive Program Analysis</h2>
          <div class="subtle">Full competitor set across direct degree competitors, adjacent design/innovation programs, AI certificate programs, and internal WGU adjacent offerings.</div>
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Segment</th>
                  <th>Provider</th>
                  <th>Program</th>
                  <th>Format</th>
                  <th>Duration</th>
                  <th>Time/Week</th>
                  <th>Price (USD)</th>
                  <th>Agentic Depth</th>
                  <th>Competency-Based</th>
                  <th>WGU Differentiation Opportunity</th>
                </tr>
              </thead>
              <tbody id="competitionRows"></tbody>
            </table>
          </div>
        </section>

        <section class="panel" id="panel-sources">
          <h2>Reputable Source Set</h2>
          <div class="subtle">Primary source list used to design demand-aligned competencies and competitive positioning.</div>
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Title</th>
                  <th>Organization</th>
                  <th>Date</th>
                  <th>URL</th>
                </tr>
              </thead>
              <tbody id="sourceRows"></tbody>
            </table>
          </div>
        </section>

        <div class="foot">Generated on #{CGI.escapeHTML(data.dig('meta', 'generated_on').to_s)} for planning purposes. Validate tuition and format details with provider pages before publication.</div>
      </div>

      <script id="program-data" type="application/json">#{json_payload}</script>
      <script>
        (function () {
          function $(id) { return document.getElementById(id); }

          function addClass(el, className) {
            if (!el) return;
            if (el.classList) { el.classList.add(className); return; }
            if ((' ' + el.className + ' ').indexOf(' ' + className + ' ') === -1) {
              el.className = (el.className ? el.className + ' ' : '') + className;
            }
          }

          function removeClass(el, className) {
            if (!el) return;
            if (el.classList) { el.classList.remove(className); return; }
            el.className = (' ' + el.className + ' ').replace(' ' + className + ' ', ' ').replace(/^\\s+|\\s+$/g, '');
          }

          function escapeHtml(str) {
            return String(str || '')
              .replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')
              .replace(/'/g, '&#39;');
          }

          function escapeAttr(str) {
            return escapeHtml(str).replace(/`/g, '&#96;');
          }

          function optionHtml(value, label) {
            return '<option value="' + escapeAttr(value) + '">' + escapeHtml(label) + '</option>';
          }

          function unique(values) {
            var seen = {};
            var out = [];
            var i;
            for (i = 0; i < values.length; i++) {
              var v = values[i];
              if (!v) continue;
              if (!seen[v]) {
                seen[v] = true;
                out.push(v);
              }
            }
            return out;
          }

          function includes(arr, value) {
            if (!arr) return false;
            return arr.indexOf(value) !== -1;
          }

          function getText(el) {
            return (el && (el.textContent || el.innerText)) || '';
          }

          function parseData() {
            var el = $('program-data');
            if (!el) {
              return {
                courses: [],
                skills_library: [],
                market_demand: [],
                sources: [],
                competitive_programs: [],
                program: { delivery_model: {}, value_proposition: [] }
              };
            }
            try {
              return JSON.parse(getText(el));
            } catch (err) {
              return {
                courses: [],
                skills_library: [],
                market_demand: [],
                sources: [],
                competitive_programs: [],
                program: { delivery_model: {}, value_proposition: [] },
                _error: String(err && err.message ? err.message : err)
              };
            }
          }

          var DATA = parseData();
          var courseTaskRows = [];
          var competencyLabel = {};

          function getEmbeddedCertificate() {
            var program = DATA.program || {};
            return program.embedded_certificate || {};
          }

          var cIdx, sIdx, tIdx, kpiCompetencies = 0;
          for (cIdx = 0; cIdx < (DATA.courses || []).length; cIdx++) {
            var course = DATA.courses[cIdx];
            var comps = course.competencies || [];
            kpiCompetencies += comps.length;
            for (sIdx = 0; sIdx < comps.length; sIdx++) {
              var comp = comps[sIdx];
              competencyLabel[comp.competency_id] = comp.competency_id + ' - ' + comp.name;
            }
            var sections = course.sections || [];
            for (sIdx = 0; sIdx < sections.length; sIdx++) {
              var section = sections[sIdx];
              var tasks = section.tasks || [];
              for (tIdx = 0; tIdx < tasks.length; tIdx++) {
                var task = tasks[tIdx];
                courseTaskRows.push({
                  courseId: course.course_id,
                  courseTitle: course.course_title,
                  sectionId: section.section_id,
                  sectionTitle: section.section_title,
                  competencies: section.competency_map || [],
                  sectionSkills: section.skills || [],
                  taskId: task.task_id,
                  taskTitle: task.title,
                  taskType: task.task_type,
                  aiEnabled: task.ai_enabled,
                  deliverable: task.deliverable
                });
              }
            }
          }

          function setKpis() {
            var embeddedCert = getEmbeddedCertificate();
            $('kpiCourses').innerHTML = (DATA.courses || []).length;
            $('kpiCompetencies').innerHTML = kpiCompetencies;
            $('kpiSkills').innerHTML = (DATA.skills_library || []).length;
            $('kpiTasks').innerHTML = courseTaskRows.length;
            $('kpiCertCourses').innerHTML = (embeddedCert.certificate_courses || []).length;
          }

          function buildSourceMap() {
            var map = {};
            var i;
            for (i = 0; i < (DATA.sources || []).length; i++) {
              map[DATA.sources[i].source_id] = DATA.sources[i];
            }
            return map;
          }

          function initOverview() {
            var program = DATA.program || {};
            var delivery = program.delivery_model || {};
            var embeddedCert = getEmbeddedCertificate();
            $('programName').innerHTML = escapeHtml(program.credential_name || '');
            $('programModality').innerHTML = escapeHtml(program.modality || '');
            $('programDuration').innerHTML = escapeHtml(program.expected_duration_months || '');
            $('embeddedCert').innerHTML = escapeHtml(embeddedCert.name || '');
            if (embeddedCert.agent_library_url) {
              $('agentLibraryLink').innerHTML =
                ' | <a href=\"' + escapeAttr(embeddedCert.agent_library_url) + '\" target=\"_blank\" rel=\"noopener\">' +
                escapeHtml(embeddedCert.agent_library_label || 'View Agent Library') + '</a>';
            } else {
              $('agentLibraryLink').innerHTML = '';
            }

            var i, html = '';
            var valueProps = program.value_proposition || [];
            for (i = 0; i < valueProps.length; i++) {
              html += '<li>' + escapeHtml(valueProps[i]) + '</li>';
            }
            $('valueList').innerHTML = html;

            var deliveryItems = [
              'Assessment type: ' + (delivery.assessment_type || ''),
              'AI environment: ' + (delivery.ai_learning_environment || ''),
              'Support model: ' + (delivery.student_support || '')
            ];
            html = '';
            for (i = 0; i < deliveryItems.length; i++) {
              html += '<li>' + escapeHtml(deliveryItems[i]) + '</li>';
            }
            $('deliveryList').innerHTML = html;

            var sourceMap = buildSourceMap();
            var md = DATA.market_demand || [];
            html = '';
            for (i = 0; i < md.length; i++) {
              var m = md[i];
              var source = sourceMap[m.source_id] || {};
              var sourceLink = source.url
                ? '<a href="' + escapeAttr(source.url) + '" target="_blank" rel="noopener">' + escapeHtml(source.title || m.source_id) + '</a>'
                : escapeHtml(m.source_id);
              html += '<div class="market-item">' +
                '<div class="theme">' + escapeHtml(m.theme) + '</div>' +
                '<div style="margin-bottom:6px;">' + escapeHtml(m.evidence) + '</div>' +
                '<div style="margin-bottom:6px;"><span class="pill">Program Implication</span> ' + escapeHtml(m.implication_for_program) + '</div>' +
                '<div class="subtle" style="margin:0;">Source: ' + sourceLink + '</div>' +
                '</div>';
            }
            $('marketList').innerHTML = html;
          }

          function initTabs() {
            var buttons = document.querySelectorAll('.tab-btn');
            var i;
            for (i = 0; i < buttons.length; i++) {
              (function (btn) {
                btn.addEventListener('click', function () {
                  var btns = document.querySelectorAll('.tab-btn');
                  var panels = document.querySelectorAll('.panel');
                  var j;
                  for (j = 0; j < btns.length; j++) removeClass(btns[j], 'active');
                  for (j = 0; j < panels.length; j++) removeClass(panels[j], 'active');
                  addClass(btn, 'active');
                  var panelId = 'panel-' + btn.getAttribute('data-tab');
                  addClass(document.getElementById(panelId), 'active');
                });
              })(buttons[i]);
            }
          }

          function initCourseFilters() {
            var courseFilter = $('courseFilter');
            var sectionFilter = $('sectionFilter');
            var competencyFilter = $('competencyFilter');

            var i, html = optionHtml('', 'All Courses');
            for (i = 0; i < (DATA.courses || []).length; i++) {
              var c = DATA.courses[i];
              html += optionHtml(c.course_id, c.course_id + ' | ' + c.course_title);
            }
            courseFilter.innerHTML = html;

            var sections = [];
            for (i = 0; i < courseTaskRows.length; i++) {
              sections.push(courseTaskRows[i].sectionId + ' | ' + courseTaskRows[i].sectionTitle);
            }
            sections = unique(sections);
            html = optionHtml('', 'All Sections');
            for (i = 0; i < sections.length; i++) html += optionHtml(sections[i], sections[i]);
            sectionFilter.innerHTML = html;

            var competencies = [];
            for (i = 0; i < courseTaskRows.length; i++) {
              var rowComps = courseTaskRows[i].competencies || [];
              var j;
              for (j = 0; j < rowComps.length; j++) competencies.push(rowComps[j]);
            }
            competencies = unique(competencies);
            html = optionHtml('', 'All Competencies');
            for (i = 0; i < competencies.length; i++) {
              var compId = competencies[i];
              html += optionHtml(compId, competencyLabel[compId] || compId);
            }
            competencyFilter.innerHTML = html;

            var ids = ['courseFilter', 'sectionFilter', 'competencyFilter', 'courseSearch'];
            for (i = 0; i < ids.length; i++) {
              var el = $(ids[i]);
              el.addEventListener('input', renderCourseRows);
              el.addEventListener('change', renderCourseRows);
            }

            $('resetCourseFilters').addEventListener('click', function () {
              courseFilter.value = '';
              sectionFilter.value = '';
              competencyFilter.value = '';
              $('courseSearch').value = '';
              renderCourseRows();
            });
          }

          function renderCourseRows() {
            var embeddedCert = getEmbeddedCertificate();
            var certCourses = embeddedCert.certificate_courses || [];
            var certLibraryUrl = embeddedCert.agent_library_url || '';
            var certLibraryLabel = embeddedCert.agent_library_label || 'View Agent Library';
            var courseValue = $('courseFilter').value;
            var sectionValue = $('sectionFilter').value;
            var competencyValue = $('competencyFilter').value;
            var query = (($('courseSearch').value || '').replace(/^\\s+|\\s+$/g, '').toLowerCase());
            var html = '';
            var i, j;

            for (i = 0; i < courseTaskRows.length; i++) {
              var row = courseTaskRows[i];
              var sectionTag = row.sectionId + ' | ' + row.sectionTitle;
              var matchesCourse = (!courseValue || row.courseId === courseValue);
              var matchesSection = (!sectionValue || sectionTag === sectionValue);
              var matchesCompetency = (!competencyValue || includes(row.competencies, competencyValue));
              var haystack = [
                row.courseId, row.courseTitle, row.sectionId, row.sectionTitle,
                row.taskId, row.taskTitle, row.taskType, row.aiEnabled, row.deliverable,
                (row.sectionSkills || []).join(' '), (row.competencies || []).join(' ')
              ].join(' ').toLowerCase();
              var matchesQuery = (!query || haystack.indexOf(query) !== -1);
              if (!(matchesCourse && matchesSection && matchesCompetency && matchesQuery)) continue;

              var competencyChips = '';
              for (j = 0; j < (row.competencies || []).length; j++) {
                var rc = row.competencies[j];
                competencyChips += '<span class="pill">' + escapeHtml(competencyLabel[rc] || rc) + '</span>';
              }
              var skillChips = '';
              for (j = 0; j < (row.sectionSkills || []).length; j++) {
                skillChips += '<span class="pill">' + escapeHtml(row.sectionSkills[j]) + '</span>';
              }
              var aiFlowHtml = escapeHtml(row.aiEnabled);
              if (certLibraryUrl && includes(certCourses, row.courseId)) {
                aiFlowHtml += '<div><a href=\"' + escapeAttr(certLibraryUrl) + '\" target=\"_blank\" rel=\"noopener\">' +
                  escapeHtml(certLibraryLabel) + '</a></div>';
              }

              html += '<tr>' +
                '<td><strong>' + escapeHtml(row.courseId) + '</strong><br>' + escapeHtml(row.courseTitle) + '</td>' +
                '<td><strong>' + escapeHtml(row.sectionId) + '</strong><br>' + escapeHtml(row.sectionTitle) + '</td>' +
                '<td>' + competencyChips + '</td>' +
                '<td>' + skillChips + '</td>' +
                '<td><strong>' + escapeHtml(row.taskId) + ' - ' + escapeHtml(row.taskTitle) + '</strong><br>' + escapeHtml(row.taskType) + '</td>' +
                '<td>' + aiFlowHtml + '</td>' +
                '<td>' + escapeHtml(row.deliverable) + '</td>' +
                '</tr>';
            }
            $('courseRows').innerHTML = html;
          }

          function initSkillFilters() {
            var i, html;
            var courseOptions = unique((DATA.skills_library || []).map(function (s) { return s.course_id; })).sort();
            html = optionHtml('', 'All Courses');
            for (i = 0; i < courseOptions.length; i++) html += optionHtml(courseOptions[i], courseOptions[i]);
            $('skillCourseFilter').innerHTML = html;

            var domainOptions = unique((DATA.skills_library || []).map(function (s) { return s.domain; })).sort();
            html = optionHtml('', 'All Domains');
            for (i = 0; i < domainOptions.length; i++) html += optionHtml(domainOptions[i], domainOptions[i]);
            $('skillDomainFilter').innerHTML = html;

            var ids = ['skillCourseFilter', 'skillDomainFilter', 'skillSearch'];
            for (i = 0; i < ids.length; i++) {
              var el = $(ids[i]);
              el.addEventListener('input', renderSkillRows);
              el.addEventListener('change', renderSkillRows);
            }

            $('resetSkillFilters').addEventListener('click', function () {
              $('skillCourseFilter').value = '';
              $('skillDomainFilter').value = '';
              $('skillSearch').value = '';
              renderSkillRows();
            });

            $('exportSkillsCsv').addEventListener('click', exportSkillsCsv);
          }

          function renderSkillRows() {
            var courseValue = $('skillCourseFilter').value;
            var domainValue = $('skillDomainFilter').value;
            var query = (($('skillSearch').value || '').replace(/^\\s+|\\s+$/g, '').toLowerCase());
            var rows = DATA.skills_library || [];
            var html = '';
            var i;
            for (i = 0; i < rows.length; i++) {
              var row = rows[i];
              var matchesCourse = (!courseValue || row.course_id === courseValue);
              var matchesDomain = (!domainValue || row.domain === domainValue);
              var haystack = [row.skill_id, row.skill_name, row.domain, row.course_id].join(' ').toLowerCase();
              var matchesQuery = (!query || haystack.indexOf(query) !== -1);
              if (!(matchesCourse && matchesDomain && matchesQuery)) continue;
              html += '<tr>' +
                '<td>' + escapeHtml(row.skill_id) + '</td>' +
                '<td>' + escapeHtml(row.skill_name) + '</td>' +
                '<td>' + escapeHtml(row.domain) + '</td>' +
                '<td>' + escapeHtml(row.course_id) + '</td>' +
                '</tr>';
            }
            $('skillsRows').innerHTML = html;
          }

          function toCsvField(value) {
            var clean = String(value || '').replace(/"/g, '""');
            return '"' + clean + '"';
          }

          function exportSkillsCsv() {
            var rowEls = document.querySelectorAll('#skillsRows tr');
            var lines = [];
            var i, j;
            for (i = 0; i < rowEls.length; i++) {
              var tdEls = rowEls[i].querySelectorAll('td');
              var fields = [];
              for (j = 0; j < tdEls.length; j++) {
                fields.push(toCsvField((tdEls[j].textContent || tdEls[j].innerText || '').replace(/^\\s+|\\s+$/g, '')));
              }
              lines.push(fields.join(','));
            }
            var csv = ['skill_id,skill_name,domain,course_id'].concat(lines).join('\\n');
            var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'ms_dbi_skills_filtered.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
          }

          function initCompetition() {
            var sourceMap = buildSourceMap();
            var rows = DATA.competitive_programs || [];
            var html = '';
            var i;
            for (i = 0; i < rows.length; i++) {
              var c = rows[i];
              var source = sourceMap[c.source_id] || {};
              var price = (c.price_usd === null || c.price_usd === undefined) ? 'Not publicly listed' : ('$' + Number(c.price_usd).toLocaleString());
              var programLink = source.url
                ? '<a href="' + escapeAttr(source.url) + '" target="_blank" rel="noopener">' + escapeHtml(c.program) + '</a>'
                : escapeHtml(c.program);
              html += '<tr>' +
                '<td>' + escapeHtml(c.segment || 'Unspecified') + '</td>' +
                '<td>' + escapeHtml(c.provider) + '</td>' +
                '<td>' + programLink + '</td>' +
                '<td>' + escapeHtml(c.format) + '</td>' +
                '<td>' + escapeHtml(c.duration) + '</td>' +
                '<td>' + escapeHtml(c.time_commitment || 'N/A') + '</td>' +
                '<td>' + escapeHtml(price) + '</td>' +
                '<td>' + escapeHtml(c.agentic_ai_depth) + '</td>' +
                '<td>' + escapeHtml(c.competency_based) + '</td>' +
                '<td>' + escapeHtml(c.wgu_gap_opportunity) + '</td>' +
                '</tr>';
            }
            $('competitionRows').innerHTML = html;
          }

          function initSources() {
            var rows = DATA.sources || [];
            var html = '';
            var i;
            for (i = 0; i < rows.length; i++) {
              var s = rows[i];
              html += '<tr>' +
                '<td>' + escapeHtml(s.source_id) + '</td>' +
                '<td>' + escapeHtml(s.title) + '</td>' +
                '<td>' + escapeHtml(s.organization) + '</td>' +
                '<td>' + escapeHtml(s.date || '') + '</td>' +
                '<td><a href="' + escapeAttr(s.url) + '" target="_blank" rel="noopener">' + escapeHtml(s.url) + '</a></td>' +
                '</tr>';
            }
            $('sourceRows').innerHTML = html;
          }

          function showError(message) {
            var foot = document.querySelector('.foot');
            if (!foot) return;
            foot.innerHTML += ' | Script warning: ' + escapeHtml(message);
          }

          try {
            setKpis();
            initTabs();
            initOverview();
            initCourseFilters();
            renderCourseRows();
            initSkillFilters();
            renderSkillRows();
            initCompetition();
            initSources();
            if (DATA._error) showError(DATA._error);
          } catch (err) {
            showError(err && err.message ? err.message : String(err));
          }
        })();
      </script>
    </body>
    </html>
  HTML
end

File.write(OUTPUT_HTML, html_template(DATA))
puts "Wrote #{OUTPUT_HTML}"

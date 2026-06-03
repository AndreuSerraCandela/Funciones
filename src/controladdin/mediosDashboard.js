(function () {
    var PROY_COLORS = ['#5c6ac4', '#0b6bcb', '#2f9e44', '#66788a'];
    var RES_COLORS = ['#94a3b8', '#0b6bcb', '#2f9e44'];
    var COLOR_PREV = '#1d7ed0';
    var COLOR_UP = '#2f9e44';
    var COLOR_EQUAL = '#b7791f';
    var COLOR_DOWN = '#d92d20';

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function num(value) {
        return new Intl.NumberFormat('es-ES', { maximumFractionDigits: 0 }).format(Number(value || 0));
    }

    function chartHitClass(action) {
        return action ? ' tip-kpi-action tip-chart-hit' : '';
    }

    function chartHitAttrs(action, year) {
        if (!action) {
            return '';
        }
        var attrs = ' data-action="' + escapeHtml(action) + '" role="button" tabindex="0"';
        if (year !== undefined && year !== null && year !== '') {
            attrs += ' data-year="' + escapeHtml(String(year)) + '"';
        }
        return attrs;
    }

    function chartItemsWithYear(items, filterYear) {
        return (items || []).map(function (item) {
            var copy = {};
            var key;
            for (key in item) {
                if (Object.prototype.hasOwnProperty.call(item, key)) {
                    copy[key] = item[key];
                }
            }
            if (!copy.year && filterYear !== undefined && filterYear !== null && filterYear !== '') {
                copy.year = filterYear;
            }
            return copy;
        });
    }

    function kpi(label, value, note, state, action, year) {
        var hit = chartHitClass(action);
        var attrs = chartHitAttrs(action, year);
        return '<div class="tip-kpi ' + escapeHtml(state || '') + '">' +
            '<div class="tip-kpi-label' + hit + '"' + attrs + '>' + escapeHtml(label) + '</div>' +
            '<div class="tip-kpi-value' + hit + '"' + attrs + '>' + escapeHtml(value) + '</div>' +
            '<div class="tip-kpi-note">' + escapeHtml(note || '') + '</div>' +
            '</div>';
    }

    function taskCell(value, label, color, action, year) {
        var hit = chartHitClass(action);
        var attrs = chartHitAttrs(action, year);
        return '<div class="tip-task-cell">' +
            '<div class="n' + hit + '"' + attrs + ' style="color:' + color + '">' + escapeHtml(value || 0) + '</div>' +
            '<div class="l' + hit + '"' + attrs + '>' + escapeHtml(label) + '</div></div>';
    }

    function taskBlock(title, block, labels, prefix, filterYear) {
        block = block || {};
        labels = labels || {};
        prefix = prefix || '';
        return '<div class="tip-card tip-card--compact"><div class="tip-card-title">' + escapeHtml(title) + '</div>' +
            '<div class="tip-task-grid tip-task-grid--4">' +
            taskCell(block.planning, labels.planning || 'Planificación', PROY_COLORS[0], prefix + '-planning', filterYear) +
            taskCell(block.quote, labels.quote || 'Presupuesto', PROY_COLORS[1], prefix + '-quote', filterYear) +
            taskCell(block.open, labels.open || 'En curso', PROY_COLORS[2], prefix + '-open', filterYear) +
            taskCell(block.completed, labels.completed || 'Completado', PROY_COLORS[3], prefix + '-completed', filterYear) +
            '</div></div>';
    }

    function segment(color, value, offset, action, year) {
        if (!value) {
            return '';
        }
        return '<circle class="tip-donut-seg' + chartHitClass(action) + '" cx="21" cy="21" r="15.915" fill="transparent" stroke="' + color + '" stroke-width="8" ' +
            'stroke-dasharray="' + value + ' ' + (100 - value) + '" stroke-dashoffset="' + (25 - offset) + '"' +
            chartHitAttrs(action, year) + '></circle>';
    }

    function donutFromItems(items, colors, centerLabel, defaultYear) {
        var total = 0;
        var offset = 0;
        var segments = '';
        var index;
        var value;
        var pct;
        var palette = colors || PROY_COLORS;

        if (!items || !items.length) {
            return '<div class="tip-empty">No hay datos con los filtros actuales.</div>';
        }

        for (index = 0; index < items.length; index += 1) {
            total += Number(items[index].value || 0);
        }
        if (!total) {
            return '<div class="tip-empty">No hay datos con los filtros actuales.</div>';
        }

        for (index = 0; index < items.length; index += 1) {
            value = Number(items[index].value || 0);
            if (!value) {
                continue;
            }
            pct = value / total * 100;
            segments += segment(palette[index % palette.length], pct, offset, items[index].action, defaultYear);
            offset += pct;
        }

        return '<svg class="tip-donut tip-donut--compact" viewBox="0 0 42 42" role="img">' +
            '<circle cx="21" cy="21" r="15.915" fill="transparent" stroke="#e8edf2" stroke-width="8"></circle>' +
            segments +
            '<text x="21" y="20" text-anchor="middle" font-size="5" font-weight="700" fill="#1f2933">' + escapeHtml(total) + '</text>' +
            '<text x="21" y="25" text-anchor="middle" font-size="3" fill="#66788a">' + escapeHtml(centerLabel || 'proyectos') + '</text>' +
            '</svg>';
    }

    function donutLegend(items, colors, showPct) {
        var index;
        var total = 0;
        var value;
        var pct;
        var palette = colors || PROY_COLORS;
        var html = '<div class="tip-legend tip-legend--compact">';
        for (index = 0; index < items.length; index += 1) {
            total += Number(items[index].value || 0);
        }
        for (index = 0; index < items.length; index += 1) {
            value = Number(items[index].value || 0);
            pct = total ? value / total * 100 : 0;
            var action = items[index].action;
            var itemClass = 'tip-legend-item';
            var labelAttrs = chartHitAttrs(action, items[index].year);
            var valueAttrs = chartHitAttrs(action, items[index].year);
            if (action) {
                itemClass += ' tip-kpi-action';
            }
            html += '<div class="' + itemClass + '">' +
                '<span class="tip-dot" style="background:' + palette[index % palette.length] + '"></span>' +
                '<span class="tip-legend-label' + chartHitClass(action) + '"' + labelAttrs + '>' + escapeHtml(items[index].label) + ':</span> ' +
                '<span class="tip-legend-value' + chartHitClass(action) + '"' + valueAttrs + '>' + escapeHtml(num(value)) +
                (showPct ? ' (' + escapeHtml(fmtPct(pct)) + ')' : '') +
                '</span></div>';
        }
        return html + '</div>';
    }

    function donutPane(title, items, colors, centerLabel, showPct, defaultYear) {
        return '<div class="tip-projects-donut-pane">' +
            '<div class="tip-card-title tip-card-title--sub">' + escapeHtml(title) + '</div>' +
            '<div class="tip-chart-row tip-chart-row--compact tip-chart-row--donut-pane">' +
            donutFromItems(items, colors, centerLabel, defaultYear) +
            donutLegend(items, colors, showPct) +
            '</div></div>';
    }

    function projectsDonutsCard(chartProyectos, chartReserva, filterYear) {
        return '<div class="tip-card tip-card--compact tip-card--projects-donuts">' +
            '<div class="tip-projects-donuts-grid">' +
            donutPane('Distribución por estado', chartProyectos || [], PROY_COLORS, 'proyectos', false, filterYear) +
            donutPane('Reservas y fijación', chartReserva || [], RES_COLORS, 'proyectos', true, filterYear) +
            '</div></div>';
    }

    function currentBarColor(current, prev) {
        if (current > prev) {
            return COLOR_UP;
        }
        if (current === prev) {
            return COLOR_EQUAL;
        }
        return COLOR_DOWN;
    }

    function fmtPct(value) {
        return new Intl.NumberFormat('es-ES', { maximumFractionDigits: 1 }).format(Number(value || 0)) + '%';
    }

    function displayValue(item, field) {
        var value = Number(item[field] || 0);
        if (item.isPercent) {
            return fmtPct(value);
        }
        return num(value);
    }

    function verticalCompareChart(items, filterYear, prevYear, maxScale) {
        var index;
        var current;
        var prev;
        var max = 1;
        var groups = '';
        var legend = '<div class="tip-compare-legend">' +
            '<span class="tip-legend-item"><span class="tip-dot" style="background:' + COLOR_PREV + '"></span>' + escapeHtml(prevYear) + ' (anterior)</span>' +
            '<span class="tip-legend-item"><span class="tip-dot" style="background:' + COLOR_UP + '"></span>' + escapeHtml(filterYear) + ' superior</span>' +
            '<span class="tip-legend-item"><span class="tip-dot" style="background:' + COLOR_EQUAL + '"></span>igual</span>' +
            '<span class="tip-legend-item"><span class="tip-dot" style="background:' + COLOR_DOWN + '"></span>inferior</span>' +
            '</div>';

        if (!items || !items.length) {
            return '<div class="tip-empty">No hay datos con los filtros actuales.</div>';
        }

        maxScale = Number(maxScale || 0);
        if (maxScale > 0) {
            max = maxScale;
        } else {
            for (index = 0; index < items.length; index += 1) {
                current = Number(items[index].value || 0);
                prev = Number(items[index].valuePrev || 0);
                max = Math.max(max, current, prev);
            }
        }

        for (index = 0; index < items.length; index += 1) {
            current = Number(items[index].value || 0);
            prev = Number(items[index].valuePrev || 0);
            var action = items[index].action;
            var prevColAttrs = chartHitAttrs(action, prevYear);
            var currColAttrs = chartHitAttrs(action, filterYear);
            var labelAttrs = chartHitAttrs(action, filterYear);
            groups += '<div class="tip-vbar-group">' +
                '<div class="tip-vbar-bars">' +
                '<div class="tip-vbar-col' + chartHitClass(action) + '"' + prevColAttrs +
                ' title="' + escapeHtml(prevYear) + ': ' + displayValue(items[index], 'valuePrev') + '">' +
                '<div class="tip-vbar-fill" style="height:' + Math.max(2, Math.round(prev / max * 100)) + '%;background:' + COLOR_PREV + '"></div>' +
                '<div class="tip-vbar-num">' + escapeHtml(displayValue(items[index], 'valuePrev')) + '</div>' +
                '</div>' +
                '<div class="tip-vbar-col' + chartHitClass(action) + '"' + currColAttrs +
                ' title="' + escapeHtml(filterYear) + ': ' + displayValue(items[index], 'value') + '">' +
                '<div class="tip-vbar-fill" style="height:' + Math.max(2, Math.round(current / max * 100)) + '%;background:' + currentBarColor(current, prev) + '"></div>' +
                '<div class="tip-vbar-num">' + escapeHtml(displayValue(items[index], 'value')) + '</div>' +
                '</div>' +
                '</div>' +
                '<div class="tip-vbar-label' + chartHitClass(action) + '"' + labelAttrs + '>' + escapeHtml(items[index].label) + '</div>' +
                '</div>';
        }

        return legend + '<div class="tip-vbar-chart">' + groups + '</div>';
    }

    function metric(label, value, css, action, year) {
        var hit = chartHitClass(action);
        var attrs = chartHitAttrs(action, year);
        return '<div class="tip-financial-item">' +
            '<div class="tip-financial-label' + hit + '"' + attrs + '>' + escapeHtml(label) + '</div>' +
            '<div class="tip-financial-value ' + escapeHtml(css || '') + hit + '"' + attrs + '>' + escapeHtml(num(value)) + '</div>' +
            '</div>';
    }

    function barsCompact(items, fillClass) {
        if (!items || !items.length) {
            return '<div class="tip-empty">Sin datos.</div>';
        }
        var max = items.reduce(function (current, item) {
            return Math.max(current, Number(item.value || 0));
        }, 0) || 1;

        return '<div class="tip-bars tip-bars--compact">' + items.map(function (item) {
            var width = Math.max(3, Math.round(Number(item.value || 0) / max * 100));
            var hit = chartHitClass(item.action);
            var attrs = chartHitAttrs(item.action, item.year);
            return '<div class="tip-bar-row tip-bar-row--compact">' +
                '<div class="tip-bar-label' + hit + '"' + attrs + ' title="' + escapeHtml(item.label) + '">' + escapeHtml(item.label) + '</div>' +
                '<div class="tip-bar-track' + hit + '"' + attrs + '><div class="tip-bar-fill ' + (fillClass || 'good') + '" style="width:' + width + '%"></div></div>' +
                '<div class="tip-bar-value' + hit + '"' + attrs + '>' + escapeHtml(num(item.value)) + '</div>' +
                '</div>';
        }).join('') + '</div>';
    }

    var BILL_COLORS = ['#2f9e44', '#b7791f'];

    function donutFromPctItems(items, centerPct, pieYear) {
        var total = 0;
        var offset = 0;
        var segments = '';
        var index;
        var value;
        var pct;

        if (!items || !items.length) {
            return '<div class="tip-empty">Sin datos.</div>';
        }

        for (index = 0; index < items.length; index += 1) {
            total += Number(items[index].value || 0);
        }
        if (!total) {
            return '<div class="tip-empty">Sin datos.</div>';
        }

        for (index = 0; index < items.length; index += 1) {
            value = Number(items[index].value || 0);
            if (!value) {
                continue;
            }
            pct = value / total * 100;
            segments += segment(BILL_COLORS[index % BILL_COLORS.length], pct, offset, items[index].action, pieYear);
            offset += pct;
        }

        return '<svg class="tip-donut tip-donut--billing" viewBox="0 0 42 42" role="img">' +
            '<circle cx="21" cy="21" r="15.915" fill="transparent" stroke="#e8edf2" stroke-width="8"></circle>' +
            segments +
            '<text x="21" y="20" text-anchor="middle" font-size="5" font-weight="700" fill="#1f2933">' + escapeHtml(fmtPct(centerPct)) + '</text>' +
            '<text x="21" y="25" text-anchor="middle" font-size="3" fill="#66788a">facturado</text>' +
            '</svg>';
    }

    function pctDonutLegend(items) {
        var index;
        var action;
        var itemClass;
        var attrs;
        var html = '<div class="tip-legend tip-legend--compact">';
        for (index = 0; index < items.length; index += 1) {
            action = items[index].action;
            itemClass = 'tip-legend-item';
            labelAttrs = chartHitAttrs(action, items[index].year);
            valueAttrs = chartHitAttrs(action, items[index].year);
            if (action) {
                itemClass += ' tip-kpi-action';
            }
            html += '<div class="' + itemClass + '">' +
                '<span class="tip-dot" style="background:' + BILL_COLORS[index % BILL_COLORS.length] + '"></span>' +
                '<span class="tip-legend-label' + chartHitClass(action) + '"' + labelAttrs + '>' + escapeHtml(items[index].label) + ':</span> ' +
                '<span class="tip-legend-value' + chartHitClass(action) + '"' + valueAttrs + '>' + escapeHtml(fmtPct(items[index].value)) + '</span>' +
                '</div>';
        }
        return html + '</div>';
    }

    function billingPieBlock(title, pieData) {
        var items;
        pieData = pieData || {};
        var pieYear = pieData.year;
        items = [
            { label: 'Facturado', value: pieData.facturado || 0, action: pieData.actionFacturado || 'fact-facturado', year: pieYear },
            { label: 'Pendiente', value: pieData.pendiente || 0, action: pieData.actionPendiente || 'fact-pendiente', year: pieYear }
        ];
        return '<div class="tip-billing-pie">' +
            '<div class="tip-billing-pie-title">' + escapeHtml(title) + '</div>' +
            '<div class="tip-chart-row tip-chart-row--compact">' +
            donutFromPctItems(items, pieData.facturado || 0, pieYear) +
            pctDonutLegend(items) +
            '</div></div>';
    }

    function contractsCompareCard(chartContratos, filterYear, prevYear, pieActual, pieAnterior) {
        return '<div class="tip-card tip-card--compact tip-card--contracts-compare">' +
            '<div class="tip-card-title">Contratos · ' + escapeHtml(filterYear) + ' vs ' + escapeHtml(prevYear) + '</div>' +
            '<div class="tip-contracts-split">' +
            '<div class="tip-contracts-bars">' +
            verticalCompareChart(chartContratos || [], filterYear, prevYear) +
            '</div>' +
            '<div class="tip-contracts-pies">' +
            billingPieBlock(escapeHtml(prevYear) + ' · a mismo día', pieAnterior) +
            billingPieBlock(escapeHtml(filterYear) + ' · a mismo día', pieActual) +
            '</div>' +
            '</div></div>';
    }

    function bars(items, fillClass) {
        if (!items || !items.length) {
            return '<div class="tip-empty">No hay datos con los filtros actuales.</div>';
        }
        var max = items.reduce(function (current, item) {
            return Math.max(current, Number(item.value || 0));
        }, 0) || 1;

        return '<div class="tip-bars">' + items.map(function (item) {
            var width = Math.max(3, Math.round(Number(item.value || 0) / max * 100));
            return '<div class="tip-bar-row">' +
                '<div class="tip-bar-label" title="' + escapeHtml(item.label) + '">' + escapeHtml(item.label) + '</div>' +
                '<div class="tip-bar-track"><div class="tip-bar-fill ' + (fillClass || 'good') + '" style="width:' + width + '%"></div></div>' +
                '<div class="tip-bar-value">' + escapeHtml(num(item.value)) + '</div>' +
                '</div>';
        }).join('') + '</div>';
    }

    function bindActions() {
        function runAction(action, year) {
            var drillYear = parseInt(year, 10);
            if (isNaN(drillYear)) {
                drillYear = 0;
            }
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('DrillDown', [action, drillYear]);
        }

        function handleActivation(event) {
            var key = event.key || event.keyCode;
            var target = event.target.closest('[data-action]');
            var dashboard;
            var defaultYear;
            if (!target) {
                return;
            }
            if (event.type === 'keydown' && key !== 'Enter' && key !== ' ' && key !== 13 && key !== 32) {
                return;
            }
            event.preventDefault();
            dashboard = document.querySelector('.tip-dashboard');
            defaultYear = dashboard ? dashboard.getAttribute('data-filter-year') : '';
            runAction(
                target.getAttribute('data-action'),
                target.getAttribute('data-year') || defaultYear || '0');
        }

        var dashboard = document.querySelector('.tip-dashboard');
        if (!dashboard) {
            return;
        }
        dashboard.addEventListener('click', handleActivation);
        dashboard.addEventListener('keydown', handleActivation);
    }

    window.Render = function (payload) {
        var data;
        var p;
        var f;
        var c;
        var labels;
        var proyTotal;
        var filterYear;
        var prevYear;
        try {
            data = JSON.parse(payload || '{}');
        } catch (error) {
            document.body.innerHTML = '<div class="tip-dashboard"><div class="tip-empty">No se pudo leer el panel.</div></div>';
            return;
        }

        p = data.proyectos || {};
        f = data.fijacion || {};
        c = data.contratos || {};
        labels = data.proyectoLabels || {};
        filterYear = data.filterYear || '';
        prevYear = data.prevYear || '';
        proyTotal = (p.planning || 0) + (p.quote || 0) + (p.open || 0) + (p.completed || 0);
        var embed = data.layoutMode === 'embed';
        var dashboardClass = 'tip-dashboard' + (embed ? ' tip-dashboard--embed' : '');
        var firmaBottomSection = '';
        if (data.portafirmas) {
            firmaBottomSection =
                '<section class="tip-row-firma-fact">' +
                '<div class="tip-card tip-card--compact"><div class="tip-card-title">Portafirmas</div><div class="tip-financial tip-financial--portafirmas">' +
                metric('Pendientes envío', data.firma.pendiente, (data.firma.pendiente || 0) > 0 ? 'tip-negative' : '', 'fir-pendiente', filterYear) +
                metric('Enviados gerencia', data.firma.gerencia, '', 'fir-gerencia', filterYear) +
                metric('Firmado Malla', data.firma.malla, '', 'fir-malla', filterYear) +
                metric('Firmado cliente', data.firma.cliente, '', 'fir-cliente', filterYear) +
                metric('Rechazado Malla', data.firma.rechMalla, (data.firma.rechMalla || 0) > 0 ? 'tip-negative' : '', 'fir-rechmalla', filterYear) +
                metric('Rechazado cliente', data.firma.rechCliente, (data.firma.rechCliente || 0) > 0 ? 'tip-negative' : '', 'fir-rechcliente', filterYear) +
                '</div></div>' +
                '<div class="tip-card tip-card--compact"><div class="tip-card-title">Firma electrónica</div>' +
                barsCompact(chartItemsWithYear(data.chartFirma, filterYear), 'good') +
                '</div></section>';
        } else {
            firmaBottomSection =
                '<section class="tip-main-grid">' +
                '<div class="tip-card tip-card--compact"><div class="tip-card-title">Firma electrónica</div>' +
                barsCompact(chartItemsWithYear(data.chartFirma, filterYear), 'good') +
                '</div></section>';
        }

        document.body.innerHTML =
            '<main class="' + dashboardClass + '" data-filter-year="' + escapeHtml(filterYear) + '" data-prev-year="' + escapeHtml(prevYear) + '">' +
            (embed ? '' : (
                '<section class="tip-header">' +
                '<div><div class="tip-title">Panel Medios</div>' +
                '<div class="tip-subtitle">Proyectos, fijación y contratos</div></div>' +
                '<div class="tip-pill">' + escapeHtml(data.period || '') + '</div>' +
                '</section>'
            )) +
            (embed && data.period ? '<div class="tip-rc-period">' + escapeHtml(data.period) + '</div>' : '') +
            '<section class="tip-kpis tip-kpis--3">' +
            kpi('Proyectos', proyTotal, 'sin fijación · abrir lista', '', 'proy-total', filterYear) +
            kpi('Fijación', f.total || 0, 'proyectos de fijación · abrir lista', 'good', 'fij-total', filterYear) +
            kpi('Contratos', (c.sinMontar || 0) + (c.pendFirma || 0) + (c.firmado || 0) + (c.modificado || 0) + (c.cancelado || 0) + (c.anulado || 0), 'contrato · abrir lista', '', 'cont-total', filterYear) +
            '</section>' +
            '<section class="tip-main-grid tip-main-grid--2 tip-section-projects">' +
            taskBlock('Proyectos por estado', p, labels, 'proy', filterYear) +
            projectsDonutsCard(data.chartProyectos, data.chartProyectosReserva, filterYear) +
            '</section>' +
            '<section class="tip-main-grid tip-main-grid--2 tip-section-contracts">' +
            '<div class="tip-card tip-card--compact"><div class="tip-card-title">Contratos por estado (' + escapeHtml(filterYear) + ')</div>' +
            '<div class="tip-financial tip-financial--contratos">' +
            metric('Sin montar', c.sinMontar, '', 'cont-sinmontar', filterYear) +
            metric('Pend. firma', c.pendFirma, (c.pendFirma || 0) > 0 ? 'tip-negative' : '', 'cont-pendfirma', filterYear) +
            metric('Firmados', c.firmado, '', 'cont-firmado', filterYear) +
            metric('Modificados', c.modificado, '', 'cont-modificado', filterYear) +
            metric('Cancelados', c.cancelado, '', 'cont-cancelado', filterYear) +
            metric('Anulados', c.anulado, '', 'cont-anulado', filterYear) +
            metric('Pdtes. renovar', c.pteRenovar || 0, (c.pteRenovar || 0) > 0 ? 'tip-negative' : '', 'cont-pterenovar', filterYear) +
            '</div></div>' +
            contractsCompareCard(data.chartContratos || [], filterYear, prevYear, data.facturacionPieActual, data.facturacionPieAnterior) +
            '</section>' +
            firmaBottomSection +
            '</main>';

        bindActions();
    };
})();

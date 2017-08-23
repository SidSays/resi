({
    afterRender: function(component, helper) {
        var ret = this.superAfterRender();
        var c = component.getElement();
        var valuePercent = isNaN(component.get("v.percentage")) ? 0 : component.get("v.percentage");
        var donutsize = component.get("v.size");
        var donutcolor = component.get("v.color");
        var donuttext = valuePercent.toFixed(0) + '%';
        var donutpercent = (valuePercent > 100) ? 100 : valuePercent;
        var status = component.get("v.status");
        var width = component.get("v.width");
        var height = component.get("v.height");
        c.appendChild(helper.barChart(valuePercent, status,  width, height, 0, 0));
        return ret;
    }
})
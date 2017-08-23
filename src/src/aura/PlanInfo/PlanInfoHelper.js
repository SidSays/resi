({
    applyFilter: function(component, collection, predicate) {
        for (var j = 0; j < collection.length; j++) {
            if (predicate(collection[j])) {
                return collection[j];
            }
        }
    },
    getShoreDate: function(component, ISODate) {
        return (ISODate.getMonth() + 1) + '/' + (ISODate.getDate()) + '/' + (ISODate.getFullYear());
    },
    // Description : US728539 - DSM to SF1 : Address Sorting This sorting function sorts the user input criteria
    // Author : Siddharth Sinha
    sorting: function(component, saddresses, criteria, type) {
        switch (criteria) {
            case "Disconnect Date":
                saddresses.sort(function(a, b) {
                    var d1 = new Date(a.Last_Disconnected_Date__c);
                    var d2 = new Date(b.Last_Disconnected_Date__c);
                    if (a.Last_Disconnected_Date__c === undefined) {
                        return 1;
                    } else if (b.Last_Disconnected_Date__c === undefined) {
                        return -1;
                    } else if (d1 === d2) {
                        return 0;
                    } else if (type === 'asc') {
                        return (d1 < d2) ? -1 : 1;
                    } else if (type === 'desc') {
                        return (d1 < d2) ? 1 : -1;
                    }
                });
                break;
            case "Knocked Date":
                saddresses.sort(function(a, b) {
                    var d1 = new Date(a.Last_Knock_Date__c);
                    var d2 = new Date(b.Last_Knock_Date__c);
                    if (a.Last_Knock_Date__c === undefined) {
                        return 1;
                    } else if (b.Last_Knock_Date__c === undefined) {
                        return -1;
                    } else if (d1 === d2) {
                        return 0;
                    } else if (type === 'asc') {
                        return (d1 < d2) ? -1 : 1;
                    } else if (type === 'desc') {
                        return (d1 < d2) ? 1 : -1;
                    }
                });
                break;
            case "Address":
                saddresses.sort(function(a, b) {
                    if (type === 'asc') {
                        return (a.Sort_Code__c > b.Sort_Code__c) ? 1 : ((b.Sort_Code__c > a.Sort_Code__c) ? -1 : 0);
                    } else if (type === 'desc') {
                        return (b.Sort_Code__c > a.Sort_Code__c) ? 1 : ((a.Sort_Code__c > b.Sort_Code__c) ? -1 : 0);
                    }
                });
                break;
            case "Name":
                saddresses.sort(function(a, b) {
                    if (type === 'asc') {
                        return (a.Name > b.Name) ? 1 : ((b.Name > a.Name) ? -1 : 0);
                    } else if (type === 'desc') {
                        return (b.Name > a.Name) ? 1 : ((a.Name > b.Name) ? -1 : 0);
                    }
                });
                break;
            case "Type":
                saddresses.sort(function(a, b) {
                    if (type === 'asc') {
                        return (a.Dwelling_Type__c > b.Dwelling_Type__c) ? 1 : ((b.Dwelling_Type__c > a.Dwelling_Type__c) ? -1 : 0);
                    } else if (type === 'desc') {
                        return (b.Dwelling_Type__c > a.Dwelling_Type__c) ? 1 : ((a.Dwelling_Type__c > b.Dwelling_Type__c) ? -1 : 0);
                    }
                });
                break;
            case "Status":
                saddresses.sort(function(a, b) {
                    if (type === 'asc') {
                        return (a.Status__c > b.Status__c) ? 1 : ((b.Status__c > a.Status__c) ? -1 : 0);
                    } else if (type === 'desc') {
                        return (b.Status__c > a.Status__c) ? 1 : ((a.Status__c > b.Status__c) ? -1 : 0);
                    }
                });
                break;
        }
        return saddresses;
    },
    // End of sorting
})
using Microsoft.Xrm.Sdk;
using System.Text.RegularExpressions;
using ContosoPackageProject;
using Microsoft.Xrm.Sdk.Query;
using System;

namespace ContosoPackageProject
{
    public class LockPermitCancelInspections : PluginBase
    {
        public LockPermitCancelInspections(string unsecureConfiguration, string secureConfiguration)
                    : base(typeof(LockPermitCancelInspections))
        {

        }

        protected override void ExecuteCdsPlugin(ILocalPluginContext localPluginContext)
        {
            if (localPluginContext == null)
            {
                throw new ArgumentNullException(nameof(localPluginContext));
            }
            var context = localPluginContext.PluginExecutionContext;
            var permitEntity = context.InputParameters["Target"] as Entity;
            //var permitEntityRef = localPluginContext.PluginExecutionContext.InputParameters["Target"] as EntityReference;
            //Entity permitEntity = new Entity(permitEntityRef.LogicalName, permitEntityRef.Id);

            localPluginContext.Trace("Updating Permit Id : " + permitEntity.Id);
            //permitEntity["statuscode"] = new OptionSetValue(330650000);

            //localPluginContext.CurrentUserService.Update(permitEntity);
            localPluginContext.Trace("Updated Permit Id " + permitEntity.Id);

            var query = String.Format(@"
<fetch version='1.0' output-format='xml-platform' mapping='logical' distinct='false'>
<entity name='contoso_inspection'>
<attribute name='contoso_inspectionid' />
<attribute name='contoso_name' />
<attribute name='statuscode' />
<order attribute='contoso_name' descending='false' />
<filter type='and'>
<condition attribute='statuscode' operator='in'>
<value>1</value>
<value>3</value>
</condition>
<condition attribute='contoso_permit' operator='eq' value='"+ permitEntity.Id + @"' />
</filter>
</entity>
</fetch>", permitEntity.Id);


            //QueryExpression qe = new QueryExpression();
            //qe.EntityName = "contoso_inspection";
            //qe.ColumnSet = new ColumnSet("statuscode");

            //ConditionExpression condition = new ConditionExpression();
            //condition.Operator = ConditionOperator.Equal;
            //condition.AttributeName = "contoso_permit";
            //condition.Values.Add(permitEntityRef.Id);

            //qe.Criteria = new FilterExpression(LogicalOperator.And);

            //qe.Criteria.Conditions.Add(condition);

            localPluginContext.Trace("Retrieving inspections for Permit Id " + permitEntity.Id);
            //var inspectionsResult = localPluginContext.CurrentUserService.RetrieveMultiple(qe);
            var inspectionsResult = localPluginContext.CurrentUserService.RetrieveMultiple(new FetchExpression(query));
            localPluginContext.Trace("Retrievied " + inspectionsResult.TotalRecordCount + " inspection records");
            
            int canceledInspectionsCount = 0;
            foreach (var inspection in inspectionsResult.Entities)
            {
                var currentValue = inspection.GetAttributeValue<OptionSetValue>("statuscode");
                if (currentValue.Value == 1 || currentValue.Value == 3)
                {
                    canceledInspectionsCount++;

                    inspection["statuscode"] = new OptionSetValue(6);
                    localPluginContext.Trace("Canceling inspection Id : " + inspection.Id);
                    localPluginContext.CurrentUserService.Update(inspection);
                    localPluginContext.Trace("Canceled inspection Id : " + inspection.Id);
                }
            }

            if (canceledInspectionsCount > 0)
            {
                localPluginContext.PluginExecutionContext.OutputParameters["CanceledInspectionsCount"] = canceledInspectionsCount + " Inspections were canceled";

            }

            if (localPluginContext.PluginExecutionContext.InputParameters.ContainsKey("Reason"))
            {
                localPluginContext.Trace("building a note reocord");
                Entity note = new Entity("annotation");
                note["subject"] = "Permit Locked";
                note["notetext"] = "Reason for locking this permit: " + localPluginContext.PluginExecutionContext.InputParameters["Reason"];
                note["objectid"] = permitEntity.ToEntityReference();
                note["objecttypecode"] = permitEntity.LogicalName;

                localPluginContext.Trace("Creating a note reocord");
                var createdNoteId = localPluginContext.CurrentUserService.Create(note);

                if (createdNoteId != Guid.Empty)
                    localPluginContext.Trace("Note record was created");
            }
        }
    }
}


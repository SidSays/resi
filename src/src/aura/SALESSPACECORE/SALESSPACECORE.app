<aura:application template="c:AppTemplate">
    <aura:handler value="{!this}" name="init" action="{!c.init}"/>

    <c:Resources ></c:Resources>
    <div class="slds">    
        <c:TopMenuNavigation ></c:TopMenuNavigation>
        <c:AppLauncher ></c:AppLauncher>
        <c:MySalesSpaceApps ></c:MySalesSpaceApps>
    </div>
</aura:application>
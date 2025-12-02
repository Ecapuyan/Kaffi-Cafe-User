# Kaffi Cafe - User Case Diagram (draw.io) - Final Version

This file contains the final, corrected XML source for a draw.io use case diagram. All necessary `<<include>>` and `<<extend>>` relationships and their labels have been added to ensure the system flow is complete and accurate.

## How to Use

1.  Open [draw.io](https://app.diagrams.net/).
2.  Go to **File > Import from > XML**.
3.  Copy the XML code block below and paste it into the dialog.
4.  Click "Import".

```xml
<mxfile host="app.diagrams.net" modified="2025-11-29T15:40:00.000Z" agent="Gemini/1.0" etag="f1n4l_v3r_s10n" version="22.1.2" type="device">
  <diagram id="a9a23c28-9c17-4e94-9b19-7d2d3a1b4c6e" name="Page-1">
    <mxGraphModel dx="1434" dy="796" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="Actor_Customer" value="Customer" style="shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;html=1;outlineConnect=0;" parent="1" vertex="1">
          <mxGeometry x="130" y="410" width="30" height="60" as="geometry" />
        </mxCell>
        <mxCell id="UC_Login" value="Login" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="50" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_Register" value="Register" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="130" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_Logout" value="Logout" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="90" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ManageProfile" value="Manage Profile" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="180" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ViewNotifications" value="View Notifications" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="290" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_BrowseMenu" value="Browse Menu / Products" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="370" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ViewProductDetails" value="View Product Details" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="370" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_AddToCart" value="Add Item to Cart" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="450" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ViewCart" value="View Cart" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="530" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_Checkout" value="Checkout" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="610" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ApplyVoucher" value="Apply Voucher" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="530" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_PlaceOrder" value="Place Order" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="610" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ViewOrderHistory" value="View Order History" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="690" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ViewOrderDetails" value="View Order Details" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="690" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_MakeReservation" value="Make Reservation" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="770" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ChatSupport" value="Chat with Support" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="320" y="850" width="140" height="70" as="geometry" />
        </mxCell>
        <mxCell id="UC_ProductRecommendations" value="Receive Product Recommendations" style="ellipse;whiteSpace=wrap;html=1;" parent="1" vertex="1">
          <mxGeometry x="540" y="450" width="140" height="70" as="geometry" />
        </mxCell>
        
        <!-- Connections from Customer -->
        <mxCell id="conn1" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_Login" edge="1"/>
        <mxCell id="conn2" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_Register" edge="1"/>
        <mxCell id="conn3" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_Logout" edge="1"/>
        <mxCell id="conn4" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_ManageProfile" edge="1"/>
        <mxCell id="conn5" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_ViewNotifications" edge="1"/>
        <mxCell id="conn6" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_BrowseMenu" edge="1"/>
        <mxCell id="conn7" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_AddToCart" edge="1"/>
        <mxCell id="conn8" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_ViewCart" edge="1"/>
        <mxCell id="conn9" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_Checkout" edge="1"/>
        <mxCell id="conn10" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_ViewOrderHistory" edge="1"/>
        <mxCell id="conn11" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_MakeReservation" edge="1"/>
        <mxCell id="conn12" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_ChatSupport" edge="1"/>
        <mxCell id="conn13" style="endArrow=none;html=1;strokeColor=#1A1A1A;" parent="1" source="Actor_Customer" target="UC_ProductRecommendations" edge="1"/>

        <!-- <<include>> Relationships -->
        <mxCell id="inc_bmenu_vdetails" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_BrowseMenu" target="UC_ViewProductDetails" edge="1"/>
        <mxCell id="inc_checkout_porder" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_Checkout" target="UC_PlaceOrder" edge="1"/>
        <mxCell id="inc_vhistory_vdetails" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ViewOrderHistory" target="UC_ViewOrderDetails" edge="1"/>
        <mxCell id="inc_login_mprofile" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ManageProfile" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_vhistory" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ViewOrderHistory" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_mres" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_MakeReservation" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_checkout" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_Checkout" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_logout" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_Logout" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_vnotif" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ViewNotifications" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_addcart" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_AddToCart" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_vcart" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ViewCart" target="UC_Login" edge="1"/>
        <mxCell id="inc_login_csupport" value="&lt;&lt;include&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ChatSupport" target="UC_Login" edge="1"/>

        <!-- <<extend>> Relationships -->
        <mxCell id="ext_checkout_voucher" value="&lt;&lt;extend&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ApplyVoucher" target="UC_Checkout" edge="1"/>
        <mxCell id="ext_bmenu_recomm" value="&lt;&lt;extend&gt;&gt;" style="endArrow=open;endSize=12;dashed=1;html=1;rounded=0;strokeColor=#1A1A1A;" parent="1" source="UC_ProductRecommendations" target="UC_BrowseMenu" edge="1"/>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

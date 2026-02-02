#!/bin/bash
set -e

# Detect primary interface
IFACE=$(ip -6 route show default | awk '{print $5}' | head -1)
IFACE=${IFACE:-eth0}

# Generate radvd.conf for on-link prefix advertisement only (NOT a router)
cat > radvd.conf << EOF
# radvd.conf - On-Link Prefix Advertisement (Non-Router Mode)
# 
# Purpose: Advertise fd1d:cafe:dada::/64 as on-link only
#          Provide RDNSS servers without becoming default gateway

interface ${IFACE} {
    # Enable Router Advertisements (required for on-link prefix)
    AdvSendAdvert on;
    
    # Conservative intervals
    MinRtrAdvInterval 30;
    MaxRtrAdvInterval 100;
    
    # CRITICAL: Do NOT advertise as default router
    # Router Lifetime = 0 means we are NOT a default gateway
    AdvDefaultLifetime 0;
    
    # Managed flags ON to match existing router and avoid conflicts
    AdvManagedFlag on;
    AdvOtherConfigFlag on;
    
    # Low preference (irrelevant since not default router, but safe)
    AdvDefaultPreference low;
    
    # Include link-layer address
    AdvSourceLLAddress on;
    AdvCurHopLimit 0;           # Set to 0 to disable (container has no permission)
    
    # ============================================================
    # ON-LINK PREFIX (NOT for auto-configuration)
    # ============================================================
    prefix fd1d:cafe:dada::/64 {
        AdvOnLink on;           # This network is on-link (reachable directly)
        AdvAutonomous off;      # Do NOT auto-configure addresses from this prefix
        AdvRouterAddr off;      # Router address not used for SLAAC
        
        # Standard lifetimes
        AdvValidLifetime 86400;      # 1 day
        AdvPreferredLifetime 14400;  # 4 hours
    };
    
    # ============================================================
    # RDNSS SERVERS
    # ============================================================
    RDNSS fd1d:cafe:dada::1:3 fd1d:cafe:dada::4 fd1d:cafe:dada::1:5 {
        AdvRDNSSLifetime 3600;  # 1 hour
    };
    
    # ============================================================
    # NO DNSSL (optional - add if needed)
    # ============================================================
    # DNSSL localdomain {
    #     AdvDNSSLLifetime 3600;
    # };
    
    # ============================================================
    # NO ROUTES ADVERTISED
    # ============================================================
    # We explicitly do NOT advertise ::/0 or any other route
};

# Additional interfaces can be added here if needed
EOF

echo "Generated radvd.conf for interface: ${IFACE}"
echo ""
echo "=== Configuration Summary ==="
echo "Interface: ${IFACE}"
echo "Mode: On-Link Prefix Only (Non-Router)"
echo "Prefix: fd1d:cafe:dada::/64 (on-link, no SLAAC)"
echo "Router Lifetime: 0 (NOT a default gateway)"
echo "ManagedFlag: on (matching existing router)"
echo "OtherConfigFlag: on (matching existing router)"
echo "RDNSS: fd1d:cafe:dada::1:3, fd1d:cafe:dada::4, fd1d:cafe:dada::1:5"
echo ""
echo "To activate: docker compose up -d"
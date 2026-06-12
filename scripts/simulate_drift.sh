#!/bin/bash
set -e

REGION="us-east-1"
RED='\033[0;31m' ; GREEN='\033[0;32m' ; YELLOW='\033[1;33m' ; NC='\033[0m'

echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║        DRIFT SIMULATION — NOT FOR PRODUCTION             ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Simulating two ABSA threat vectors:${NC}"
echo "  1. EC2 instance termination  (resource deletion)"
echo "  2. Security Group rule removal  (stealthy misconfiguration)"
echo ""
sleep 2

# Terminate EC2 
echo -e "${YELLOW}[Vector 1/2] Locating running EC2 instance (web-server-dev)...${NC}"
INSTANCE_ID=$(aws ec2 describe-instances \
  --region "$REGION" \
  --filters "Name=tag:Name,Values=web-server-dev" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text 2>/dev/null)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
  echo -e "${RED}ERROR: No running web-server-dev instance found.${NC}"
  echo "       Run terraform apply in environments/dev first."
  exit 1
fi

echo "  Found: $INSTANCE_ID"
echo -e "${RED}  Terminating...${NC}"
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION" > /dev/null
echo -e "${GREEN}  Done. Instance terminating.${NC}"
echo ""

#Remove HTTP ingress rule
echo -e "${YELLOW}[Vector 2/2] Locating Security Group (web-sg-dev)...${NC}"
SG_ID=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters "Name=group-name,Values=web-sg-dev" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

if [ -z "$SG_ID" ] || [ "$SG_ID" = "None" ]; then
  echo "  WARNING: Security group not found. Skipping Vector 2."
else
  echo "  Found: $SG_ID"
  echo -e "${RED}  Revoking HTTP port 80 rule silently...${NC}"
  aws ec2 revoke-security-group-ingress \
    --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 \
    --region "$REGION" 2>/dev/null \
    && echo -e "${GREEN}  Done. Rule removed.${NC}" \
    || echo "  (Rule already absent)"
fi

echo ""
echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}  DRIFT SIMULATION COMPLETE${NC}"
echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}What just happened:${NC}"
echo "  • EC2 $INSTANCE_ID → TERMINATED"
echo "  • Security Group $SG_ID → port 80 rule REMOVED"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${GREEN}Show the drift:${NC}   cd environments/dev && terraform plan"
echo -e "  ${GREEN}Heal it:${NC}          terraform apply"
echo -e "  ${GREEN}Verify:${NC}           open http://\$(terraform output -raw web_server_public_ip)"
echo ""
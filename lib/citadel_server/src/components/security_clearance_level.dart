part of citadel_server.components;

class SecurityClearanceLevel extends Component {
  String securityClearance;

  SecurityClearanceLevel([this.securityClearance = 'everyone']);

  bool betterThan(String otherSecurityLevel)
    => _map[securityClearance] >= _map[otherSecurityLevel];
}

final _map = {
  'everyone': 0,
  'secure': 1,
  'awesome': 9,
};



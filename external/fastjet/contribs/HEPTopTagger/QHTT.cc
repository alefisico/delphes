#include "./QHTT.hh"

QHTT::QHTT() : _niter(100),   _q_zcut(0.1), _q_dcut_fctr(0.5), _q_exp_min(0.), _q_exp_max(0.), _q_rigidity(0.1), _q_truncation_fctr(0.0)
{};
void QHTT::run(HEPTopTagger::HEPTopTagger htt) {
  htt.get_setting(); 
  _weight_q1 = -1.;
  _weight_q2 = -1.;
  _m_sum = 0.;
  _m2_sum = 0.;
  _eps_q = 0.;
  _qtags = 0;
  HEPTopTagger::HEPTopTagger _htt_q = htt;
  _htt_q.set_qjets(_q_zcut, _q_dcut_fctr, _q_exp_min, _q_exp_max, _q_rigidity, _q_truncation_fctr);
  _htt_q.do_qjets(true);
  for (int iq = 0; iq < _niter; iq++) {
    _htt_q.run();
    if (_htt_q.is_tagged()) {
      _qtags++;
      _m_sum += _htt_q.t().m();
      _m2_sum += _htt_q.t().m() * _htt_q.t().m();
      if (_htt_q.q_weight() > _weight_q1) {
	_weight_q2 = _weight_q1; _htt_q2 = _htt_q1;
	_weight_q1=_htt_q.q_weight(); _htt_q1 = _htt_q;
      } else if (_htt_q.q_weight() > _weight_q2) {
	_weight_q2=_htt_q.q_weight(); _htt_q2 = _htt_q;
      }
    }
  }
  _eps_q = float(_qtags)/float(_niter);
}; 

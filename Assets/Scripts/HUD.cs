using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using TMPro;
using DG.Tweening;

public class HUD : MonoBehaviour
{
    #region Attributes
    [Header("Height")]
    [SerializeField] private float _heightShowDuration = 2f;
    [SerializeField] private float _heightTextFadeSpeed = 0.4f;
    [SerializeField] private string _heightFormat = "Height reached : {0}";
    [SerializeField] private TextMeshProUGUI _heightText = null;

    [Space]
    [SerializeField] private GameButton _resetButton = null;
    [SerializeField] private GameButton _confirmButton = null;

    [Space]
    [SerializeField] private Slider _strengthSlider = null;
    [SerializeField] private Slider _energySlider = null;

    [Space]
    [SerializeField] private Color _defaultValueTextColor = Color.white;
    [SerializeField] private Color _selectedValueTextColor = Color.white;

    [Space]
    [Header("Energy Values, from bottom to top")]
    [SerializeField] private List<TextMeshProUGUI> _values = new List<TextMeshProUGUI>();

    [Header("References")]
    [SerializeField] private EnergyManager _energyManager = null;
    #endregion

    #region Events
    public UnityEvent OnConfirmRequest = new UnityEvent();
    public UnityEvent OnResetRequest = new UnityEvent();
    #endregion

    #region Methods
    private void Start()
    {
        _confirmButton.OnClick.AddListener(OnConfirm);
        _resetButton.OnClick.AddListener(OnReset);
        _energySlider.onValueChanged.AddListener(OnEnergyValueChanged);

        _heightText.DOFade(0f, 0f);
    }

    public void SetEnergyValues(int[] values)
    {
        for (int i = 0; i < values.Length; ++i)
        {
            _values[i].text = values[i].ToString();
        }

        _energySlider.maxValue = _energyManager.MaxEnergy;
    }

    private void OnEnergyValueChanged(float value)
    {
        foreach (TextMeshProUGUI val in _values)
        {
            int intVal = 0;
            int.TryParse(val.text, out intVal);

            val.color = (intVal <= value) ? _selectedValueTextColor : _defaultValueTextColor;
        }

        _strengthSlider.value = _energyManager.Strength;
    }
    private void OnConfirm()
    {
        OnConfirmRequest.Invoke();
    }
    private void OnReset()
    {
        _energySlider.value = _energyManager.MaxEnergy;
        OnResetRequest.Invoke();
    }

    private void ShowHeight(float height)
    {
        StartCoroutine(ShowHeightTextCoroutine(height));
    }
    private IEnumerator ShowHeightTextCoroutine(float height)
    {
        _heightText.text = string.Format(_heightFormat, height);
        _heightText.DOFade(1f, _heightTextFadeSpeed);

        yield return new WaitForSeconds(_heightShowDuration);

        _heightText.DOFade(0f, _heightTextFadeSpeed);
    }
    #endregion
}

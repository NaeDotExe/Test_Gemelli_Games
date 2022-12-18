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
    [SerializeField, TextArea(5, 10)] private string _heightFormat = "Height reached : {0}";
    [SerializeField] private TextMeshProUGUI _heightText = null;

    [Space]
    [SerializeField] private GameButton _resetButton = null;
    [SerializeField] private GameButton _confirmButton = null;

    [Space]
    [SerializeField] private float _strengthFillDuration = 2.0f;
    [SerializeField] private Slider _strengthSlider = null;
    [SerializeField] private Slider _energySlider = null;

    [Space]
    [SerializeField] private Color _defaultValueTextColor = Color.white;
    [SerializeField] private Color _selectedValueTextColor = Color.white;

    [Space]
    [Header("Energy Values, from bottom to top")]
    [SerializeField] private TMP_FontAsset _regularFont = null;
    [SerializeField] private TMP_FontAsset _selectedFont = null;
    [SerializeField] private List<TextMeshProUGUI> _values = new List<TextMeshProUGUI>();

    [Header("References")]
    [SerializeField] private EnergyManager _energyManager = null;
    [SerializeField] private Entity _entity = null;

    private bool _canUpdateHeight = false;
    private float _height = 0f;
    #endregion

    #region Properties
    public bool CanUpdateHeight
    {
        get { return _canUpdateHeight; }
        set { _canUpdateHeight = value; }
    }
    #endregion

    #region Events
    public UnityEvent OnConfirmRequest = new UnityEvent();
    public UnityEvent OnResetRequest = new UnityEvent();
    public UnityEvent OnSliderFilled = new UnityEvent();
    public UnityEvent<float> OnEnergyChanged = new UnityEvent<float>();
    #endregion

    #region Methods
    private void Start()
    {
        _confirmButton.OnClick.AddListener(OnConfirm);
        _resetButton.OnClick.AddListener(OnReset);
        _energySlider.onValueChanged.AddListener(OnEnergyValueChanged);

        _heightText.DOFade(0f, 0f);
    }
    private void Update()
    {
        if (_canUpdateHeight)
        {
            float crt = _entity.Height;
            float prev = _height;

            if (prev > crt)
            {
                _canUpdateHeight = false;
            }

            UpdateHeight(_entity.Height);
        }
    }

    public void SetEnergyValues(int[] values)
    {
        for (int i = 0; i < values.Length; ++i)
        {
            _values[i].text = values[i].ToString();
            _values[i].color = _selectedValueTextColor;
            _values[i].font = _selectedFont;
        }

        _energySlider.maxValue = _energyManager.MaxEnergy;
        _energySlider.value = _energySlider.maxValue;

    }
    private void OnEnergyValueChanged(float value)
    {
        foreach (TextMeshProUGUI val in _values)
        {
            int intVal = 0;
            int.TryParse(val.text, out intVal);

            val.color = (intVal <= value) ? _selectedValueTextColor : _defaultValueTextColor;
            val.font = (intVal <= value) ? _selectedFont : _regularFont;
        }

        //_strengthSlider.value = _energyManager.Strength;
        OnEnergyChanged.Invoke(value);
    }

    private void FillSlider()
    {
        StartCoroutine(FillCoroutine());
    }
    private IEnumerator FillCoroutine()
    {
        // fill slider
        float val = (float)_energyManager.CurrentEnergy / (float)_energyManager.MaxEnergy;

        _strengthSlider.DOValue(val, _strengthFillDuration);
        yield return new WaitForSeconds(_strengthFillDuration);

        OnSliderFilled.Invoke();

        // empty slider
        _strengthSlider.DOValue(0f, _strengthFillDuration * 1.5f);
    }

    public void ShowHeight(bool show)
    {
        _height = 0f;
        _heightText.DOFade(show ? 1f : 0f, show ? 0.5f : 1.5f);

        if (!show)
        {
            _confirmButton.Interactable = true;
        }
    }
    private void UpdateHeight(float height)
    {
        _heightText.text = string.Format(_heightFormat, Mathf.Round(height * 100f) / 100f);
        _height = height;
    }

    private void OnConfirm()
    {
        _confirmButton.Interactable = false;

        FillSlider();

        OnConfirmRequest.Invoke();
    }
    private void OnReset()
    {
        _energySlider.value = _energyManager.MaxEnergy;
        OnResetRequest.Invoke();
    }
    #endregion
}

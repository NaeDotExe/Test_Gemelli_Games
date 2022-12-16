using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnergyManager : MonoBehaviour
{
    #region Attributes
    [SerializeField] private int _valuesCount = 5;
    [SerializeField] private int _maxEnergy = 50;
    
    [Space]
    [SerializeField] private HUD _hud = null;
    [SerializeField] private Entity _entity = null;

    private int _crtEnergy = 0;
    private int _midValue = 25;
    private int[] _values;
    #endregion

    #region Properties
    public int CurrentEnergy
    {
        get { return _crtEnergy; }
    }
    public int MaxEnergy
    {
        get { return _maxEnergy; }
    }
    public float Strength
    {
        get { return _crtEnergy / _maxEnergy; }
    }
    public int[] Values
    {
        get { return _values; }
    }
    #endregion

    #region Methods
    private void Start()
    {
        _crtEnergy = _maxEnergy;
        _midValue = _maxEnergy / 2;

        InitEnergyValues();
    }
    private void InitEnergyValues()
    {
        _values = new int[_valuesCount];

        float step = _maxEnergy / _valuesCount;
        float crt = step;
        
        for (int i = 0; i < _valuesCount; ++i)
        {
            _values[i] = (int)crt;
            crt += step;
        }

        _hud.SetEnergyValues(_values);
    }

    public void ResetEnergy()
    {
        _crtEnergy = _maxEnergy;
    }

    public int GetEnergyValue(int id)
    {
        if (id >= _values.Length)
        {
            Debug.LogError("Invalid Index.");
            return 0;
        }

        return _values[id];
    }
    #endregion
}

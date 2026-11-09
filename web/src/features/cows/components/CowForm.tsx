import { useState, type FormEvent } from 'react'
import type { AcquisitionSource, Cow, CowCreateInput, CowGender, CowPurpose } from '../types'

type CowFormProps = {
  initial?: Cow
  submitLabel: string
  pending?: boolean
  onSubmit: (input: CowCreateInput) => void
}

function emptyOrNull(value: string): string | null {
  const trimmed = value.trim()
  return trimmed ? trimmed : null
}

export function CowForm({ initial, submitLabel, pending, onSubmit }: CowFormProps) {
  const [tagNumber, setTagNumber] = useState(initial?.tag_number ?? '')
  const [name, setName] = useState(initial?.name ?? '')
  const [breed, setBreed] = useState(initial?.breed ?? '')
  const [dateOfBirth, setDateOfBirth] = useState(initial?.date_of_birth ?? '')
  const [purpose, setPurpose] = useState<CowPurpose>(initial?.purpose ?? 'milk')
  const [gender, setGender] = useState<CowGender>(initial?.gender ?? 'female')
  const [color, setColor] = useState(initial?.color ?? '')
  const [weight, setWeight] = useState(initial?.weight ?? '')
  const [age, setAge] = useState(initial?.age != null ? String(initial.age) : '')
  const [acquiredBy, setAcquiredBy] = useState<AcquisitionSource>(
    initial?.acquired_by ?? 'born_on_farm',
  )
  const [purchaseDate, setPurchaseDate] = useState(initial?.purchase_date ?? '')
  const [purchasePrice, setPurchasePrice] = useState(initial?.purchase_price ?? '')
  const [notes, setNotes] = useState(initial?.notes ?? '')

  function handleSubmit(event: FormEvent) {
    event.preventDefault()
    const input: CowCreateInput = {
      tag_number: tagNumber.trim(),
      purpose,
      gender,
      acquired_by: acquiredBy,
      name: emptyOrNull(name),
      breed: emptyOrNull(breed),
      date_of_birth: emptyOrNull(dateOfBirth),
      color: emptyOrNull(color),
      weight: emptyOrNull(weight),
      age: age.trim() ? Number(age) : null,
      notes: emptyOrNull(notes),
      purchase_date: acquiredBy === 'purchased' ? emptyOrNull(purchaseDate) : null,
      purchase_price: acquiredBy === 'purchased' ? emptyOrNull(purchasePrice) : null,
    }
    onSubmit(input)
  }

  return (
    <form className="form-stack" onSubmit={handleSubmit}>
      <div className="row-2">
        <div className="field">
          <label htmlFor="tag_number">Tag number</label>
          <input
            id="tag_number"
            value={tagNumber}
            onChange={(e) => setTagNumber(e.target.value)}
            required
          />
        </div>
        <div className="field">
          <label htmlFor="name">Name</label>
          <input id="name" value={name} onChange={(e) => setName(e.target.value)} />
        </div>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="purpose">Purpose</label>
          <select
            id="purpose"
            value={purpose}
            onChange={(e) => setPurpose(e.target.value as CowPurpose)}
          >
            <option value="milk">Milk</option>
            <option value="meat">Meat</option>
            <option value="both">Both</option>
          </select>
        </div>
        <div className="field">
          <label htmlFor="gender">Gender</label>
          <select
            id="gender"
            value={gender}
            onChange={(e) => setGender(e.target.value as CowGender)}
          >
            <option value="female">Female</option>
            <option value="male">Male</option>
            <option value="unknown">Unknown</option>
          </select>
        </div>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="breed">Breed</label>
          <input id="breed" value={breed} onChange={(e) => setBreed(e.target.value)} />
        </div>
        <div className="field">
          <label htmlFor="color">Color</label>
          <input id="color" value={color} onChange={(e) => setColor(e.target.value)} />
        </div>
      </div>

      <div className="row-2">
        <div className="field">
          <label htmlFor="date_of_birth">Date of birth</label>
          <input
            id="date_of_birth"
            type="date"
            value={dateOfBirth}
            onChange={(e) => setDateOfBirth(e.target.value)}
          />
        </div>
        <div className="field">
          <label htmlFor="age">Age (years)</label>
          <input
            id="age"
            type="number"
            min={0}
            value={age}
            onChange={(e) => setAge(e.target.value)}
          />
        </div>
      </div>

      <div className="field">
        <label htmlFor="weight">Weight</label>
        <input
          id="weight"
          inputMode="decimal"
          value={weight}
          onChange={(e) => setWeight(e.target.value)}
        />
      </div>

      <div className="field">
        <label htmlFor="acquired_by">Acquired by</label>
        <select
          id="acquired_by"
          value={acquiredBy}
          onChange={(e) => setAcquiredBy(e.target.value as AcquisitionSource)}
        >
          <option value="born_on_farm">Born on farm</option>
          <option value="purchased">Purchased</option>
        </select>
      </div>

      {acquiredBy === 'purchased' ? (
        <div className="row-2">
          <div className="field">
            <label htmlFor="purchase_date">Purchase date</label>
            <input
              id="purchase_date"
              type="date"
              value={purchaseDate}
              onChange={(e) => setPurchaseDate(e.target.value)}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="purchase_price">Purchase price</label>
            <input
              id="purchase_price"
              inputMode="decimal"
              value={purchasePrice}
              onChange={(e) => setPurchasePrice(e.target.value)}
              required
            />
          </div>
        </div>
      ) : null}

      <div className="field">
        <label htmlFor="notes">Notes</label>
        <textarea
          id="notes"
          rows={3}
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
        />
      </div>

      <button className="btn btn-primary" type="submit" disabled={pending}>
        {pending ? 'Saving…' : submitLabel}
      </button>
    </form>
  )
}
